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

## Inages

Images are published here on [Docker Hub](https://hub.docker.com/r/fireflycons/msktutil)

There are two variants
1. Image containing only `msktutil`.
1. Image also containing `kubectl` for use in Kubernetes clusters where you may want to write keytabs to a Kubernetes secret, for instance a CronJob that keeps a machine credential updated.

## Running the container

When starting the container, bind-mount a directory in the host file system to the container's `/keytab` directory so that the generated keytab can be retrieved easily and copied to the server that needs it.

**Shell**

```bash
docker run -it --mount type=bind,source="$(pwd)",target=/keytab fireflycons/msktutil
```

**PowerShell**

```powershell
docker run -it --mount type=bind,source="$((Get-Location).Path)",target=/keytab fireflycons/msktutil
```

This will drop you at a bash command prompt

1. Configure your domain...

    ```bash
    update-krb5-conf -r example.com -a dc01 -k dc01
    ```

    where

    * `-r` - Kerberos Realm (Active Directory domain)
    * `-a` - Hostname (within domain) of Kerberos Admin server. This is normally the primary domain controller (e.g. `dc01`).
    * `-k` - Hostname (within domain) of Kerberos Key Distribution Centre server. This is also normally the primary domain controller (e.g. `dc01`).

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