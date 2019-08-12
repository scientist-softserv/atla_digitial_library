## Prerequisites
[Ansible](http://docs.ansible.com/intro_installation.html) 1.9 or above.

## Configuration of AWS Stack found here
https://docs.google.com/a/notch8.com/document/d/1uyQIvK_WngvnwWTaCbOqessNSd32imC3q8MS-f7YZZY/edit?usp=sharing

## Provision new box

Copy group_vars/sample_all to gorup_vars/all and fill in all TODOs
Copy ec2.ini.sample to ec2.ini and fill in AWS keys at bottom
Place AWS and Deploy keys in keys subdirectory

```
./bin/provision tomcat create
./bin/provision web create
```

## Deploy new version

```
./bin/deploy
```

## Origins
This ansible playbook set was created by Notch8 for Atla, based on the work done by Data Curation Experts for the Chemical Heritage Foundation.


## TODO
It would be nice to have this stack work in vagrant again or local docker stack
Auto addition to the load balancers of new servers
