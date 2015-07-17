defmodule WindowToggler do
  require Logger

  @num_horizontal_workspaces 4
  @num_vertical_workspaces 3

  def main(_args) do
    current_window = active_window_id
    monitor_size = monitor_size
    window_list = window_list
    workspace_window_list = windows_on_workspace(window_list, monitor_size)
    next_window = get_next_window(workspace_window_list, current_window)
    focus_window(next_window)
  end

  def hostname do
    'hostname'
    |> :os.cmd
    |> to_string
    |> String.strip
  end

  def pid_of(name) do
    "ps fax | grep '#{name}' | awk 'NR==1{print $1}'"
    |> String.to_char_list
    |> :os.cmd
    |> to_string
    |> String.strip
  end

  def active_window_id do
    ~c(xprop -root | grep _NET_ACTIVE_WINDOW | head -1 | awk '{print $5}' | sed 's/^0x/0x0/')
    |> :os.cmd
    |> to_string
    |> String.strip
  end

  def window_list do
    hostname = hostname
    compiz_pid = pid_of("compiz")
    ~s(wmctrl -lGp | grep -v -e '#{hostname} Desktop' | awk '{print $1" "$3" "$4" "$5" "$6" "$7" "$9" "$10}')
    |> String.to_char_list
    |> :os.cmd
    |> to_string
    |> String.strip
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.reject(fn (window) -> Enum.at(window, 1) == compiz_pid end)
  end

  def windows_on_workspace(window_list, [width, height]) do
    window_list
    |> Enum.filter(&on_workspace?(&1, width, height))
  end

  def on_workspace?(window, width, height) do
    dx = Enum.at(window, 2) |> String.to_integer
    dy = Enum.at(window, 3) |> String.to_integer

    (dx > 0) and (dx < width) and (dy > 0) and (dy < height)
  end

  def monitor_size do
    ~c(xrandr | grep '*' | awk '{print $1}')
    |> :os.cmd
    |> to_string
    |> String.strip
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
  end

  def get_next_window(window_list, actual_window_id) do
    following_windows =
      Enum.drop_while(window_list, &(get_window_id(&1) != actual_window_id))

    case following_windows do
      [_, window | _] -> get_window_id(window)
      _ -> hd(window_list) |> get_window_id
    end
  end

  def focus_window(id) do
    ~c(wmctrl -i -a #{id}) |> :os.cmd
  end

  def get_window_id(window) do
    Enum.at(window, 0)
  end
end
