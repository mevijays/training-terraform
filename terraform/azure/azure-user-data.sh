#cloud-config
package_upgrade: true
package_update: true
packages:
        - vim
        - bash-completion
        - git
        - gcc
        - net-tools
        - curl
        - wget
        - httpd
runcmd:
  - curl -fsSL https://get.docker.com | sh
  - usermod -aG docker vijay
  - systemctl enable httpd && systemctl start httpd
write_files:
- owner: apache:apache
  permissions: '0644'
  content: |
    <h1>KR Network Cloud Web! </h1><br>
    <h1>Hello from VM1 </h1>
  path: /var/www/html/index.html

users:
  - name: vijay
    groups: wheel
    lock_passwd: false
    passwd: $6$L6sXilzFo0ZmsuN7$VvAopTMjoL62tW1Sr64YCWRXiaFjx4UA36lNgS7A2lK3AYsxRMKhB1PXA88cwmVW0U3aPU8xD2xhkrSDkM3rN1
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5QqtH1y7NC/jJ8pOGzeQ90n8XuESQ+JMQovkhS/CFdGeh2Il0KDgFWvbxrkVUlnPEHCSTKEm92jLXfhlzGxX/5KSgkzRAgOQpsCP29nvjcFMVoyErcVen0KrQmhf7njg92lQIEyymNGNhd8b5gONXxHd0PpsOMT5wtvt9CZoN8aJu32+JT844xljp9tyirgptyJQdcjqb/rNKPh5vrRcPF4gRcQEMXRtLiXJfZ6Mg67/rLYO6oDrZSApG5oyS+JZx/g/mEuGeeVkOF+Ivc8Iq0AiWewJrjb/8e93lH14x5LaURkhZmRKIQfk7Fg5BRzIgboJBf8MvEDsBoftaOx2r vijay@virus
  - name: root
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5QqtH1y7NC/jJ8pOGzeQ90n8XuESQ+JMQovkhS/CFdGeh2Il0KDgFWvbxrkVUlnPEHCSTKEm92jLXfhlzGxX/5KSgkzRAgOQpsCP29nvjcFMVoyErcVen0KrQmhf7njg92lQIEyymNGNhd8b5gONXxHd0PpsOMT5wtvt9CZoN8aJu32+JT844xljp9tyirgptyJQdcjqb/rNKPh5vrRcPF4gRcQEMXRtLiXJfZ6Mg67/rLYO6oDrZSApG5oyS+JZx/g/mEuGeeVkOF+Ivc8Iq0AiWewJrjb/8e93lH14x5LaURkhZmRKIQfk7Fg5BRzIgboJBf8MvEDsBoftaOx2r vijay@virus
power_state:
  mode: reboot
  message: Post config done! Rebooting now.........
  condition: True
