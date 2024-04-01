# - Ansible Task: Deploy one an opensource websites using ansible. Your ansible slave will consist of one ubuntu node and one centos(rhel) node. Your master node can be of any Linux distribution of your choice (3 nodes in all). Explore using variables in ansible while executing this task.
## SOLUTION:
* Spin up three Linux machines using vagrant. Two ubuntu servers and one centos server. One of the ubuntu machines has been designated as the master-node while the other two machines are the slave-nodes.
* The next step is to generate a ssh key for your master-node by running the command `ssh-keygen`. 
* Then run`ssh-copy-id username@ipaddress` in the `.ssh/` directory of the master-node. the username will be the username of the slavenode, while the ipaddress is the ipaddress of the slavenode. This command copies the `publickey` of the master-node into the `authorized_keys` of the various slave-nodes
* Next is to install ansible using `sudo apt install ansible`. Then run `sudo apt update` to update the package manager.
* Create folder named ansible. cd into the ansible folder.

### STEP ONE:
>Create host file and ansible config file
* The host file contains the ipaddress of the slave-node and the ansible.cfg file contains configuration settings. Here a host file named `hosts` contains two ipaddresses of the slave-node, while the `ansible.cfg` contains desired settings. See terminal output below.
```
vagrant@master-node:~/ansible$ cat hosts
[webservers]
192.168.56.10
192.168.56.11

vagrant@master-node:~/ansible$ cat ansible.cfg
[defaults]
roles = os.path.join(os.path.dirname(__file__), 'roles')
inventory = hosts
remost_user = vagrant
host_key_checking = false

[privilege_escalations]
become = true
become_method = sudo
become_user = root
become_ack_password = false

vagrant@master-node:~/ansible$ 

```
### STEP TWO: 
> Create roles directory and playbooks
* The roles directory contains the apache2 directory while contains three other directories namely- defaults, handlers, tasks, templates. These folders contain different plays with a file name `main.yml`.
* Also a YAML file has been created in the ansible directly named `main_playbook`.
* The contents of these files are displayed below:

main_playbook -

```
vagrant@master-node:~/ansible$ cat main_playbook.yml 
---

- name: Role to install Apache2 on Debian and RedHat
  hosts: webservers
  become: true
  roles:
    - name: apache2

```
roles/apache2/tasks/main.yml -

```
vagrant@master-node:~/ansible/roles$ cd apache2
vagrant@master-node:~/ansible/roles/apache2$ cd tasks
vagrant@master-node:~/ansible/roles/apache2/tasks$ cat main.yml 
---
---
- name: Task to install Apache2 on Ubuntu
  apt:
    name: apache2
    state: present
  when: ansible_os_family == 'Debian'

- name: Copy custome page
  ansible.builtin.copy:
    src: /home/vagrant/ansible/WP-Pusher-Altschool-Exercise/WP PUSHER/
    dest: /var/www/html/
    owner: root
    group: root
    mode: '0644'
  when: ansible_os_family == 'Debian'

- name: Task to install Apache2 on CentOs
  yum:
    name: httpd
    state: present
  when: ansible_os_family == 'RedHat'

- name: Copy custome page
  ansible.builtin.copy:
    src: /home/vagrant/ansible/WP-Pusher-Altschool-Exercise/WP PUSHER/
    dest: /var/www/html/
    owner: root
    group: root
    mode: '0644'
  when: ansible_os_family == 'RedHat'

- name: restart httpd
  service: 
    name: httpd
    state: restarted
  when: ansible_os_family == 'RedHat'
  
```
roles/apache2/handlers/main.yml -

```
vagrant@master-node:~/ansible/roles/apache2$ cd handlers
vagrant@master-node:~/ansible/roles/apache2/handlers$ cat main.yml 
---

- name: start apache2 server
  service:
    name: apache2
    state: started
    enabled: yes
  when: ansible_os_family == 'Debian'

- name: restart apache2
  service: 
    name: apache2
    state: restarted
  when: ansible_os_family == 'Debian'

- name: start httpd server
  service:
    name: httpd
    state: started
    enabled: yes
  when: ansible_os_family == 'RedHat'

- name: restart httpd
  service: 
    name: httpd
    state: restarted

```


roles/apache2/defaults/main.yml -

```
vagrant@master-node:~/ansible/roles/apache2$ cd defaults
vagrant@master-node:~/ansible/roles/apache2/defaults$ cat main.yml 
---
default_variables_for_roles: "This is default variables for roles"
name: apache2

```
> The website to be rendered on the slave-node has been cloned into the ansible directory. In the handlers playbook this repository was copied into the `var/www/html/` directory using the copy module.

### THIRD STEP:
> Execute the playbook into the slave-nodes
* Run the command `ansible-playbook -i hosts main_playbook`

```
vagrant@master-node:~/ansible$ ansible-playbook -i hosts main_playbook.yml

PLAY [Role to install Apache2 on Debian and RedHat] ********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
[WARNING]: Platform linux on host 192.168.56.11 is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python
interpreter could change this. See https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information.
ok: [192.168.56.11]
ok: [192.168.56.10]

TASK [apache2 : Task to install Apache2 on Ubuntu] *********************************************************************************************************
skipping: [192.168.56.10]
changed: [192.168.56.11]

TASK [apache2 : Task to install Apache2 on CentOs] *********************************************************************************************************
skipping: [192.168.56.11]
changed: [192.168.56.10]

PLAY RECAP *************************************************************************************************************************************************
192.168.56.10              : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
192.168.56.11              : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0 

```

