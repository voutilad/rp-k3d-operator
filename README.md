# rp-k3d-operator

beep boop

## You'll Need

- Linux host with 16 MiB or more memory
- recent version of Docker
- root access via `sudo` most likely
- all the [Tools](#tools) installed

## Tools

If you're in a hurry and trust the world is puppies and unicorns and aren't
afraid of executing random stuff from the internet as root, fire off some
`curl`s piped into `bash` to install the tooling you'll need:

- kubectl:
```sh
if [ x`uname -m` = "xaarch64" ]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
else
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
fi
chmod 0755 kubectl && sudo mv kubectl /usr/local/bin && sudo chown root:root /usr/local/bin/kubectl
```

- kustomize:
```sh
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | sudo bash -s /usr/local/bin
```

- k3d:
```sh
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

- Helm:
```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

- Flux: 
```sh
curl -s https://fluxcd.io/install.sh | sudo FLUX_VERSION=2.0.0 bash
```