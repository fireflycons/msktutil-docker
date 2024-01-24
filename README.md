# msktutil-docker

`msktutil` is a program for interoperability with Active Directory that can:
 - Create a computer account in Active Directory
 - Create a service account in Active Directory
 - Create a system Kerberos keytab
 - Create a Kerberos keytab for a dedicated service
 - Add and remove principals to and from keytabs
 - Change the account's password

This repo contains the things required to build a containerised version of `msktutil` from its source code [here](https://github.com/msktutil/msktutil), allowing it to be run on any machine that can run docker, e.g. Windows.

A common use of this tool is to [create a keytab](https://wiki.squid-cache.org/ConfigExamples/Authenticate/Kerberos#create-keytab) for use by Squid's [Kerberos Negotiate Authentication](https://wiki.squid-cache.org/Features/NegotiateAuthentication) when running [Squid](http://www.squid-cache.org/) on Linux in combination with Windows or Samba Active Directory.

## Building the image

You'll need the following information

* `REALM` - The active directory domain to authenticate with (e.g. `example.com`)
* `ADMIN_SERVER` - Hostname (within domain) of Kerberos Admin server. This is normally the primary domain controller (e.g. `dc01`).
* `KDC_SERVER` - Hostname (within domain) of Kerberos Key Distribution Centre server. This is also normally the primary domain controller (e.g. `dc01`).

Replace `example.com` and `dc01` with appropriate values for your domain

**Bash**

```
docker build -t msktutil \
     --build-arg REALM=example.com \
     --build-arg ADMIN_SERVER=dc01 \
     --build-arg KDC_SERVER=dc01 \
     .
```

**PowerShell**
```
docker build -t msktutil `
     --build-arg REALM=example.com `
     --build-arg ADMIN_SERVER=dc01 `
     --build-arg KDC_SERVER=dc01 `
     .
```

## Running the container

When starting the container, bind-mount a directory in the host file system to the container's `/keytab` directory so that the generated keytab can be retrieved easily and copied to the server that needs it.

**Bash**

```bash
docker run -it --mount type=bind,source="$(pwd)",target=/keytab msktutil
```

**PowerShell**

```powershell
docker run -it --mount type=bind,source="$((Get-Location).Path)",target=/keytab msktutil
```

This will drop you at a bash command prompt

1. Authenticate with your domain as a user that has rights to create Active Directory objects

    ```bash
    kinit administrator
    ```

1. Now you can run `msktutil` to create your keytabs. The following example creates a keytab based on the squid wiki documentation. Adjust for your OU (`-b` argument), domain (`-s`, `-h`, `--upn`, `--server`), primary domain controller (`--server`), and the target machine host name if not `squid`.<br/><br/>Note `-k` argument should be set to write the keytab to the bind-mounted directory.

    ```bash
    msktutil create \
        -b "CN=COMPUTERS" \
        -s HTTP/squid.example.com \
        -h squid.example.com \
        -k /keytab/HTTP.keytab \
        --computer-name squid \
        --upn HTTP/squid.example.com \
        --server dc01.example.com \
        --verbose \
        --enctypes 28 \
        --no-reverse-lookups
    ```