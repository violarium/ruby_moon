environment "production"

app_root = File.expand_path(File.dirname(__FILE__) + '/../')

bind  "unix://#{app_root}/tmp/sockets/puma.sock"
pidfile "#{app_root}/tmp/pids/puma.pid"
state_path "#{app_root}/tmp/pids/puma.state"

activate_control_app
