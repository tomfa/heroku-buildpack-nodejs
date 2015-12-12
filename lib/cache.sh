source $BP_DIR/lib/binaries.sh

create_signature() {
  echo "$(node --version); $(npm --version)"
}

save_signature() {
  echo "$(create_signature)" > $CACHE_DIR/node/signature
}

load_signature() {
  if test -f $CACHE_DIR/node/signature; then
    cat $CACHE_DIR/node/signature
  else
    echo ""
  fi
}

get_cache_status() {
  if ! ${NODE_MODULES_CACHE:-true}; then
    echo "disabled by config"
  elif [ "$(create_signature)" != "$(load_signature)" ]; then
    echo "new runtime signature"
  else
    echo "valid"
  fi
}

get_cache_directories() {
  local dirs1=$(read_json "$BUILD_DIR/package.json" ".cacheDirectories | .[]?")
  local dirs2=$(read_json "$BUILD_DIR/package.json" ".cache_directories | .[]?")

  if [ -n "$dirs1" ]; then
    echo "$dirs1"
  else
    echo "$dirs2"
  fi
}

restore_cache_directories() {
  local build_dir=${1:-}
  local cache_dir=${2:-}

  for cachepath in ${@:3}; do
    if ! [ -e "$cache_dir/node/$cachepath" ]; then
      mkdir -p $cache_dir/node/$cachepath
    fi
    if [ -e "$build_dir/$cachepath" ]; then
      if ! [ -L "$build_dir/$cachepath" ]; then
        echo "- $cachepath (exists - moving files then deleting - its not a link)"
        ls $build_dir
        ls $build_dir/$cachepath
        cp -r "$build_dir/$cachepath/". "$cache_dir/node/$cachepath"
        rm -rf $build_dir/$cachepath
      fi
    fi
    echo "- linking $cachepath"
    ln -s "$cache_dir/node/$cachepath" "$build_dir/$cachepath"
  done
}

clear_cache() {
  echo "- ignore clear_cache() (due to link)"
}

save_cache_directories() {
  echo "- ignore save directories (due to link)"
}
