# Salt Pex

A way to build [Salt](https://saltstack.com/) using [pex](https://pex.readthedocs.io/en/stable/)
and package the executable using FreeBSD's [pkgng](https://wiki.freebsd.org/pkgng).

It allows for a completely isolated environment for Salt.

## Use

Best to run this inside a jail since it'll be installing additional packages that
are required for Salt and pex. Assuming we are in a jail:
```sh
git clone https://github.com/sarcasticadmin/salt-pex.git
cd salt-pex
sh salt-pex.sh pkg
```

This will create a `BUILD` directory and output the pkg in the root of that directory.

Push up that pkg to a custom pkgng repo or install it directly:
```sh
pkg install salt-call-pex
rehash
salt-call --local --version
```

## Limitations
1. Due to the single entrypoint in pex, this method of building salt is limited to a
single binary. In this case the script currently uses `salt-call` allowing for
masterless configuration.
2. Some modules in salt might have issues with installing salt in this way. The
majority should be fine however.
