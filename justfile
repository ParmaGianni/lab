mod clusters
mod kustomizations
mod talos

# switch context
switch:
    case $CLUSTER_BRANCH in \
        dev) echo "use flake .#prod" > .envrc; direnv reload;; \
        prod) echo "use flake ." > .envrc; direnv reload;; \
    esac
# creates a cluster for local development and testing
@create:
    echo "Pick a backend:"; \
    echo ""; \
    echo "0) k3d"; \
    echo "1) talos"; \
    echo ""; \
    read -p "Choose [0..1]: " choice; \
    case $choice in \
        0) just clusters::_k3d;; \
        1) just talos::apply -i;; \
        *) exit 1;; \
    esac
# destroys and cleans up a local cluster
@destroy:
    echo "Pick a backend:"; \
    echo ""; \
    echo "0) k3d"; \
    echo "1) talos"; \
    echo ""; \
    read -p "Choose [0..1]: " choice; \
    case $choice in \
        0) k3d cluster delete $CLUSTER_BRANCH;; \
        1) just talos::_destroy;; \
        *) exit 1;; \
    esac

# reusable guard-rail to prevent unwanted alterations to the production environment
@_guard:
    if [ "$(kconf ls | rg "\*.*sleepy")" != "" ] || \
    [ "$(kconf ls | rg "\*.*k8s")" != "" ] || \
    [ "$(talosctl config contexts | rg "\*.*sleepy")" != "" ] || \
    [ "$CLUSTER_BRANCH" = "prod" ]; then \
        echo "You are in the danger zone! Do you want to continue?"; \
        read -p "Input '--prod-prod-prod' to continue: " choice; \
        case $choice in \
           --prod-prod-prod) exit 0;; \
            *) exit 1;; \
        esac \
    else \
        exit 0; \
    fi; \
