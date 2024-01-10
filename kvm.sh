#!/bin/bash

read -p "create disk or virtual machine?(1 or 2)": parameter

until [ $parameter = 1 ] || [ $parameter = 2 ] 

do
    echo unknow parameter, plase try again.
    read -p "create disk or virtual machine?(1 or 2)": parameter
done

case $parameter in
    1)
        read -p "virtual machine disk name:"  disk_name

        while [ -e /virtual_machine/$disk_name.qcow2 ]
        do
            echo virtal machine already exist, please try again.
            read -p "virtual machine disk name:"  disk_name
        done

        read -p "virtual machine disk size:"  disk_size

        if qemu-img create -f qcow2 /virtual_machine/$disk_name.qcow2 $disk_size -o preallocation=metadata >> /dev/null ; then
            echo virtal machine disk created
        fi
        ;;
    2)
        # getting thin disk parameters

        read -p "virtual machine disk name:"  disk_name

        while [ -e /virtual_machine/$disk_name.qcow2 ]
        do
            echo virtal machine already exist, please try again.
            read -p "virtual machine disk name:"  disk_name
        done

        read -p "virtual machine disk size:"  disk_size



        # getting VM name

        read -p "virtual machine name:" virtual_machine_name

        while [ -e /etc/libvirt/qemu/$virtual_machine_name ]   # Check if the virtual machine exists
        do
            echo $virtual_machine_name is already exist, please try again.
            read -p "virtual machine name:" virtual_machine_name
        done

        # getting VM memory

        read -p "virtual machine memory size(number):" virtual_machine_memory

        while [ $virtual_machine_memory -gt 15720 ]
        do
            echo $virtual_machine_memory is too large, please try again.
            read -p "virtual machine memory size:" virtual_machine_memory
        done



        # getting number of VM vcpu

        read -p "number of virtual machine vcpus(number):" virtual_machine_vcpus

        while [ $virtual_machine_vcpus -gt 16 ]
        do
            echo $virtual_machine_vcpus is too large, please try again.
            read -p "virtual machine memory size:" virtual_machine_vcpus
        done



        # getting ISO

        read -p "virtual machine ISO (centos7/centos8/rhel8/centos_stream8):" ISO  

        until [ $ISO = centos7 ] || [ $ISO = centos8 ] || [ $ISO = rhel8 ] || [ $ISO = centos_stream8 ] &> /dev/null # 检查镜像是否正确   
        do
            unknown ISO, please try again.
            read -p "virtual machine ISO (centos7/centos8/rhel8/centos_stream8):" ISO
        done

        case $ISO in 
            centos7)
                ISO=/ISO/CentOS-7-x86_64-DVD-2009.iso ;;
            centos8)
                ISO=/ISO/CentOS-8.4.2105-x86_64-dvd1.iso ;;
            centos_stream8)
                ISO=/ISO/CentOS-Stream-8-x86_64-latest-dvd1.iso ;;
            rhel8)
                ISO=/ISO/rhel-8.4-x86_64-dvd.iso ;;
        esac

        # automatic installtion 

        read -p "automatic installtion machine(yes/no):" auto_install  

        until  [ $auto_install = yes ] || [ $auto_install = no ] 
        do
            unknown parameter, please input "yes" or "no".
            read -p "automatic installtion machine(yes/no):" auto_install
        done

        if [ $auto_install = yes ] ; then 
            address = "-x ks=http://192.168.122.121/ks/ks.cfg"
        fi
        

        # creating thin disk and VM

        if qemu-img create -f qcow2 /virtual_machine/$disk_name.qcow2 $disk_size -o preallocation=metadata >> /dev/null ; then
            echo virtal machine disk created
        fi

        sudo virt-install \
          --name $virtual_machine_name \
          --memory $virtual_machine_memory \
          --vcpus $virtual_machine_vcpus \
          --location $ISO \
          --disk path=/virtual_machine/$disk_name.qcow2 \
          --network network=default \
          --noautoconsole \
          $address
        ;;
esac