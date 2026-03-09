-- Helper function to actually execute the command in the chosen pane
local function execute_in_pane(pane_id, cmd, is_idle)
  if not is_idle then
    -- Interrupt the busy pane first
    os.execute(string.format("tmux send-keys -t %s C-c", pane_id))
    vim.cmd("sleep 150m") -- Give zsh/bash time to cleanly redraw the prompt
  end
  -- Send the code to run
  os.execute(string.format("tmux send-keys -t %s '%s' Enter", pane_id, cmd))
end

-- The new Smart Pane Router
local function send_to_tmux(cmd)
  if not vim.env.TMUX then
    print("Not inside a tmux session!")
    return
  end

  -- 1. Query tmux for all panes in the current window
  -- Returns: PaneID | IsActive(0/1) | CurrentCommand | PaneName
  local format = "#{pane_id}|#{pane_active}|#{pane_current_command}|Pane #{pane_index}"
  local lines = vim.fn.systemlist("tmux list-panes -F '" .. format .. "'")

  local idle_panes = {}
  local busy_panes = {}

  -- 2. Categorize the panes
  for _, line in ipairs(lines) do
    local id, active, current_cmd, name = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")

    -- Ignore the pane Neovim is currently running in (active == "1")
    if active == "0" then
      local is_idle = (current_cmd == "zsh" or current_cmd == "bash" or current_cmd == "fish")
      local pane_info = { id = id, cmd = current_cmd, name = name, is_idle = is_idle }

      if is_idle then
        table.insert(idle_panes, pane_info)
      else
        table.insert(busy_panes, pane_info)
      end
    end
  end

  local total_other_panes = #idle_panes + #busy_panes

  -- Scenario A: No other panes exist -> Create one
  if total_other_panes == 0 then
    local raw_id = vim.fn.system("tmux split-window -v -p 30 -d -P -F '#{pane_id}'")
    local target_pane = raw_id:gsub("%s+", "")
    vim.cmd("sleep 100m")
    execute_in_pane(target_pane, cmd, true)
    return
  end

  -- Scenario B: Exactly ONE other pane -> Just use it automatically
  if total_other_panes == 1 then
    local target = idle_panes[1] or busy_panes[1]
    execute_in_pane(target.id, cmd, target.is_idle)
    return
  end

  -- Scenario C: MULTIPLE other panes -> Show the smart menu
  local options = {}
  -- Insert idle panes first so they appear at the top
  for _, p in ipairs(idle_panes) do
    table.insert(options, p)
  end
  -- Insert busy panes below
  for _, p in ipairs(busy_panes) do
    table.insert(options, p)
  end

  vim.ui.select(options, {
    prompt = "Select Target Tmux Pane:",
    format_item = function(item)
      local status_icon = item.is_idle and "🟢 [IDLE]" or "🔴 [BUSY]"
      return string.format("%s %s (Running: %s)", status_icon, item.name, item.cmd)
    end,
  }, function(choice)
    -- This callback runs after you select an item from the menu
    if not choice then
      return
    end -- User pressed Esc/aborted
    execute_in_pane(choice.id, cmd, choice.is_idle)
  end)
end

-- Helper function to make asking for arguments less repetitive
local function ask_args(prompt_text, callback)
  vim.ui.input({ prompt = prompt_text }, function(input)
    callback(input or "")
  end)
end

-- Function 1: Run the current file interactively
local function run_file_in_tmux()
  vim.cmd("silent! update")

  local file = vim.fn.expand("%")
  local file_no_ext = vim.fn.expand("%:r")
  local file_ext = vim.fn.expand("%:e")

  -- 1. COMPILED LANGUAGES
  if file_ext == "c" then
    ask_args("C compile args (e.g. -Wall -g): ", function(c_args)
      ask_args("Execution args: ", function(run_args)
        local cmd = string.format(
          "gcc %s -o %s %s && ./%s %s",
          file,
          file_no_ext,
          c_args,
          file_no_ext,
          run_args
        )
        send_to_tmux(cmd)
      end)
    end)
  elseif file_ext == "cpp" or file_ext == "cc" then
    ask_args("C++ compile args (e.g. -Wall -g): ", function(cpp_args)
      ask_args("Execution args: ", function(run_args)
        local cmd = string.format(
          "g++ %s -o %s %s && ./%s %s",
          file,
          file_no_ext,
          cpp_args,
          file_no_ext,
          run_args
        )
        send_to_tmux(cmd)
      end)
    end)
  elseif file_ext == "rs" then
    ask_args("Rustc compile args: ", function(rs_args)
      ask_args("Execution args: ", function(run_args)
        local cmd = string.format("rustc %s %s && ./%s %s", file, rs_args, file_no_ext, run_args)
        send_to_tmux(cmd)
      end)
    end)

  -- 2. INTERPRETED LANGUAGES
  elseif file_ext == "py" then
    ask_args("Python execution args: ", function(run_args)
      send_to_tmux(string.format("python3 %s %s", file, run_args))
    end)
  elseif file_ext == "js" then
    ask_args("Node execution args: ", function(run_args)
      send_to_tmux(string.format("node %s %s", file, run_args))
    end)
  elseif file_ext == "ts" then
    ask_args("TS-Node execution args: ", function(run_args)
      send_to_tmux(string.format("ts-node %s %s", file, run_args))
    end)
  elseif file_ext == "sh" then
    ask_args("Bash execution args: ", function(run_args)
      send_to_tmux(string.format("bash %s %s", file, run_args))
    end)
  elseif file_ext == "go" then
    ask_args("Go run args: ", function(run_args)
      send_to_tmux(string.format("go run %s %s", file, run_args))
    end)
  else
    print("No interactive tmux command defined for: ." .. file_ext)
  end
end

-- Function 2: Run the entire project interactively
local function run_project_in_tmux()
  vim.cmd("silent! wa")

  if vim.fn.filereadable("Makefile") == 1 then
    ask_args("Make args (e.g. clean, test): ", function(args)
      send_to_tmux("make " .. args)
    end)
  elseif vim.fn.filereadable("Cargo.toml") == 1 then
    ask_args("Cargo args (e.g. --release): ", function(args)
      send_to_tmux("cargo run " .. args)
    end)
  elseif vim.fn.filereadable("package.json") == 1 then
    ask_args("NPM script (default: start): ", function(args)
      local script = args == "" and "start" or "run " .. args
      send_to_tmux("npm " .. script)
    end)
  else
    print("No project file found. Falling back to Run File.")
    run_file_in_tmux()
  end
end

-- Function 3: Smart Close Runner Pane
local function close_runner_pane()
  if not vim.env.TMUX then
    print("Not inside a tmux session!")
    return
  end

  -- 1. Query tmux for all panes in the current window
  local format = "#{pane_id}|#{pane_active}|#{pane_current_command}|Pane #{pane_index}"
  local lines = vim.fn.systemlist("tmux list-panes -F '" .. format .. "'")

  local other_panes = {}

  -- 2. Gather all panes EXCEPT the one Neovim is currently in
  for _, line in ipairs(lines) do
    local id, active, current_cmd, name = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")

    if active == "0" then
      local is_idle = (current_cmd == "zsh" or current_cmd == "bash" or current_cmd == "fish")
      table.insert(other_panes, { id = id, cmd = current_cmd, name = name, is_idle = is_idle })
    end
  end

  -- Scenario A: No panes to close
  if #other_panes == 0 then
    print("No active runner panes to close!")
    return
  end

  -- Scenario B: Exactly one pane -> kill it instantly
  if #other_panes == 1 then
    os.execute(string.format("tmux kill-pane -t %s > /dev/null 2>&1", other_panes[1].id))
    return
  end

  -- Scenario C: Multiple panes -> Ask which one to kill
  vim.ui.select(other_panes, {
    prompt = "Select Tmux Pane to KILL:",
    format_item = function(item)
      local status_icon = item.is_idle and "🟢 [IDLE]" or "🔴 [BUSY]"
      return string.format("%s %s (Running: %s)", status_icon, item.name, item.cmd)
    end,
  }, function(choice)
    -- This runs after you select an item from your fzf UI
    if not choice then
      return
    end
    os.execute(string.format("tmux kill-pane -t %s > /dev/null 2>&1", choice.id))
  end)
end

-- Bind the functions to your preferred keys
vim.keymap.set(
  "n",
  "<leader>crf",
  run_file_in_tmux,
  { desc = "Run File in Tmux (Interactive)", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>crp",
  run_project_in_tmux,
  { desc = "Run Project in Tmux (Interactive)", noremap = true, silent = true }
)

vim.keymap.set(
  "n",
  "<leader>crc",
  close_runner_pane,
  { desc = "Close Runner Pane", noremap = true, silent = true }
)
