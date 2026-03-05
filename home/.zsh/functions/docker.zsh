docker-fzf() {
  local type
  type=$(printf "containers\nimages\nvolumes\nnetworks" | fzf --prompt="docker > ")

  case "$type" in
    containers)
      local container
      container=$(docker ps -a --format "{{.Names}}\t{{.Image}}\t{{.Status}}" | \
        fzf --prompt="container > " | awk '{print $1}')

      [ -z "$container" ] && return

      local action
      action=$(printf "logs\nshell\nrestart\nstop\ninspect\nrm" | \
        fzf --prompt="$container > ")

      case "$action" in
        logs) docker logs -f "$container" ;;
        shell) docker exec -it "$container" sh ;;
        restart) docker restart "$container" ;;
        stop) docker stop "$container" ;;
        inspect) docker inspect "$container" | less ;;
        rm) docker rm "$container" ;;
      esac
      ;;
    images)
      docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" | \
        fzf --prompt="image > "
      ;;
    volumes)
      docker volume ls --format "{{.Name}}" | \
        fzf --prompt="volume > "
      ;;
    networks)
      docker network ls --format "{{.Name}}" | \
        fzf --prompt="network > "
      ;;
  esac
}
docker-fzf-widget() { docker-fzf }
zle -N docker-fzf-widget

