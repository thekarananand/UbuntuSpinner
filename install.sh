clear

# VARIBALES DEFINED

CONFIG=/home/$USER/.config/UbuntuSpinner
EXTENSIONS=/home/$USER/.local/share/gnome-shell/extensions

# CREATING REQUIRED DIRECTORY

mkdir -p $CONFIG

if [[ ! -f "$CONFIG/.PROMPTED" ]]
then

    if zenity --question --no-wrap --title='Ubuntu Spinner' --text='Do you want to Default Apps ?\n\nThis will install VSCODE + OnlyOffice + Calculus + Notion (Unofficial) + WhatsApp for Linux (Unofficial)'
    then
        touch $CONFIG/.DEFAULT
    fi

    if zenity --question --title='Ubuntu Spinner' --text='Do you want Laptop Specific Settings?'
    then
        touch $CONFIG/.LAPTOP
    fi

	if zenity --question --title='Ubuntu Spinner' --text='Do you want Switchable Graphics?\n\nIt is recommended to install NVIDIA Drives beforehand, if you are using NVIDIA GPU.'
    then
        touch $CONFIG/.SwitchableGraphics
    fi

	if zenity --question --title='Ubuntu Spinner' --text='Do you want Ubuntu Dash?\n\nPress No to Replace it with Gnome-Dock'
    then
        touch $CONFIG/.keepDASH
    fi

	touch $CONFIG/.PROMPTED
fi

# Setting-up the BASE SYSTEM
if [[ ! -f "$CONFIG/.BaseSystem1" ]]
then
    # Disable Wayland 

		sudo sed -i "s/#WaylandEnable=false/WaylandEnable=false/g" /etc/gdm3/custom.conf
		# Restart / Logout Required for above Command.
    
    # Install Pre-Req
    	
		# Repo for nala
		echo "deb [arch=amd64,arm64,armhf] http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
		wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null
		
		sudo apt update
		sudo apt install nala git curl -y

    # APT : Preferences, Repos, & Mirrors

		# Repo for VS CODE
		wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
		sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
		sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
		rm -f packages.microsoft.gpg
		
        # Repo for JETBRAINS (UNOFFICIAL) Source : https://github.com/JonasGroeger/jetbrains-ppa/
		curl -s https://s3.eu-central-1.amazonaws.com/jetbrains-ppa/0xA6E8698A.pub.asc | gpg --dearmor | sudo tee /usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg > /dev/null
		echo "deb [signed-by=/usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg] http://jetbrains-ppa.s3-website.eu-central-1.amazonaws.com any main" | sudo tee /etc/apt/sources.list.d/jetbrains-ppa.list > /dev/null

        # Repo for Grub Customizer
		sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y

        # Repo for Flatpak
		sudo add-apt-repository ppa:flatpak/stable -y  
		
        # Repo for Mozilla Firefox
		sudo add-apt-repository ppa:mozillateam/ppa -y
	    
        # Repo for Android Studio
		sudo add-apt-repository ppa:maarten-fonville/android-studio -y
		
	# APT Preferances for NO Snaps
		touch nosnap.pref
		echo "Package: snapd" >> ./nosnap.pref
		echo "Pin: release a=*" >> ./nosnap.pref
		echo "Pin-Priority: -10" >> ./nosnap.pref
		sudo mv ./nosnap.pref /etc/apt/preferences.d/
		
        # APT Preferances for Debian Package of Firefox not Snap
		touch mozillateamppa
		echo "Package: firefox*" >> ./mozillateamppa
		echo "Pin: release o=LP-PPA-mozillateam" >> ./mozillateamppa
		echo "Pin-Priority: 501" >> ./mozillateamppa
		sudo mv ./mozillateamppa /etc/apt/preferences.d/

		sudo nala update 

        # APT mirrors
        	sudo nala fetch --auto -y

    # Clean Up

		sudo nala remove --purge snapd remmina* libreoffice* rhythmbox* thunderbird* gnome-mines gnome-mahjongg gnome-sudoku aisleriot gnome-system-monitor gnome-calendar gnome-todo totem transmission-gtk gnome-startup-applications simple-scan usb-creator-* transmission-common ubuntu-docs shotwell* gnome-user-docs yelp xorg-docs-core -y
		
		if [[ ! -f "$CONFIG/.keepDASH" ]]
		then
			sudo nala remove --purge gnome-shell-extension-ubuntu-dock -y
		fi
		
		sudo nala clean
		sudo nala autoremove -y

    # Flatpak Setup
    	
		sudo nala install flatpak -y
    		sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # Upgating Existing Packages
		
		sudo nala upgrade -y

		sudo flatpak update -y

    # Base Apps
		sudo nala install firefox vlc grub-customizer preload htop gnome-tweaks ubuntu-restricted-extras stacer -y
    		sudo flatpak install flathub com.mattjakeman.ExtensionManager -y

    # Laptop Specific Packages & Config
		if [[ -f "$CONFIG/.LAPTOP" ]]
		then
			# Repo for Touchegg
			sudo add-apt-repository ppa:touchegg/stable -y
			sudo nala update
			
			sudo nala install tlp tlp-rdw touchegg -y 

			sudo tlp start
			sudo systemctl enable tlp.service
			sudo systemstl start tlp.service
			
		fi

    # Install New Software-Store
    
    		# I am currently in search of a better software store like Pop-Shop.
    		# Building Pop-Shop from source brought some bugs.
    
    		# But Temporarily
    
    		sudo nala install gnome-software gnome-software-plugin-flatpak -y
    
    # Install Extensions 
    
		mkdir .extensions
		cd .extensions

		wget https://extensions.gnome.org/extension-data/blur-my-shellaunetx.v43.shell-extension.zip
		wget https://extensions.gnome.org/extension-data/date-menu-formattermarcinjakubowski.github.com.v7.shell-extension.zip
		wget https://extensions.gnome.org/extension-data/just-perfection-desktopjust-perfection.v22.shell-extension.zip
		wget https://extensions.gnome.org/extension-data/theme-switcherfthx.v5.shell-extension.zip
		wget https://extensions.gnome.org/extension-data/lockkeysvaina.lt.v47.shell-extension.zip
		wget https://extensions.gnome.org/extension-data/drive-menugnome-shell-extensions.gcampax.github.com.v51.shell-extension.zip
		wget https://extensions.gnome.org/extension-data/user-themegnome-shell-extensions.gcampax.github.com.v49.shell-extension.zip
		
		if [[ -f "$CONFIG/.LAPTOP" ]]
		then
			wget https://extensions.gnome.org/extension-data/x11gesturesjoseexposito.github.io.v14.shell-extension.zip
		fi
		
		unzip blur-my-shellaunetx.v43.shell-extension.zip -d ./blur-my-shell@aunetx/
		unzip date-menu-formattermarcinjakubowski.github.com.v7.shell-extension.zip -d ./date-menu-formatter@marcinjakubowski.github.com/
		unzip just-perfection-desktopjust-perfection.v22.shell-extension.zip -d ./just-perfection-desktop@just-perfection/
		unzip theme-switcherfthx.v5.shell-extension.zip -d ./theme-switcher@fthx/
		unzip lockkeysvaina.lt.v47.shell-extension.zip -d ./lockkeys@vaina.lt/
		unzip drive-menugnome-shell-extensions.gcampax.github.com.v51.shell-extension.zip -d ./drive-menu@gnome-shell-extensions.gcampax.github.com/
		unzip user-themegnome-shell-extensions.gcampax.github.com.v49.shell-extension.zip -d ./user-theme@gnome-shell-extensions.gcampax.github.com/
		
		if [[ -f "$CONFIG/.LAPTOP" ]]
		then
			unzip x11gesturesjoseexposito.github.io.v14.shell-extension.zip -d ./x11gestures@joseexposito.github.io/
		fi
		
		rm blur-my-shellaunetx.v43.shell-extension.zip
		rm date-menu-formattermarcinjakubowski.github.com.v7.shell-extension.zip
		rm just-perfection-desktopjust-perfection.v22.shell-extension.zip
		rm theme-switcherfthx.v5.shell-extension.zip
		rm lockkeysvaina.lt.v47.shell-extension.zip
		rm drive-menugnome-shell-extensions.gcampax.github.com.v51.shell-extension.zip
		rm user-themegnome-shell-extensions.gcampax.github.com.v49.shell-extension.zip
		
		if [[ -f "$CONFIG/.LAPTOP" ]]
		then
			rm x11gesturesjoseexposito.github.io.v14.shell-extension.zip
		fi
		
		mkdir -p $EXTENSIONS
		cp * $EXTENSIONS -r 
		
		cd ..
		
		rm -r ./.extensions
	
    # GRUB CUSTOMIZER

		sudo mkdir -p "/boot/grub/themes/"
		sudo cp -a ./grubthemes/* /boot/grub/themes/
		
		sudo cp /etc/default/grub ./
		sudo rm /etc/default/grub
		
		sed -i '/GRUB_GFXMODE=/d' ./grub
		sed -i '/GRUB_TIMEOUT=/d' ./grub
		sed -i '/GRUB_TIMEOUT_STYLE=/d' ./grub
		sed -i '/GRUB_THEME=/d' ./grub

		echo 'GRUB_GFXMODE="auto"' >> ./grub 
		echo 'GRUB_TIMEOUT="10"' >> ./grub
		echo 'GRUB_TIMEOUT_STYLE="menu"' >> ./grub
		echo 'GRUB_THEME="/boot/grub/themes/Sleek-Dark/theme.txt"' >> ./grub
		
		sudo mv ./grub /etc/default/

		sudo update-grub
		
		clear
		echo "+-------------------+"
		echo "|  Grub Customizer  |"
		echo "+-------------------+"
		echo ""
		echo "Step 1 : In \"List Configuration\" tab, Configure the Boot Enteries."
		echo ""
		echo "Step 2 : In \"Appearance Settings\" tab, Set a Custom Resolution & Select a Theme."
		echo ""
		echo "               +------+"
		echo "Step 3 : Press | Save | then EXIT Grub Customizer Pop-up Window !!...."
		echo "               +------+"
		sudo grub-customizer >> null
		clear
		rm null
		
	touch $CONFIG/.BaseSystem1

	zenity --info --title='Ubuntu Spinner' --text='This system needs RESTART. Press [OK] to RESTART. After the System restarts, please Re-Execute this Script...'
	reboot

fi

if [[ ! -f "$CONFIG/.BaseSystem2" ]]
then
	
	# Install Pop-Shell
    	sudo apt install make node-typescript -y
		git clone https://github.com/pop-os/shell
		cd shell
		make local-install
		cd ..
		sudo rm -r shell

	# Installing Switchable Graphics
		if [[ -f "$CONFIG/.SwitchableGraphics" ]]
		then
			sudo apt-add-repository ppa:system76-dev/stable
			sudo apt install gnome-shell-extension-system76-power system76-power
		fi

	# Enabling Extensions
		gnome-extensions enable blur-my-shell@aunetx
		gnome-extensions enable date-menu-formatter@marcinjakubowski.github.com
		gnome-extensions enable drive-menu@gnome-shell-extensions.gcampax.github.com
		gnome-extensions enable just-perfection-desktop@just-perfection
		gnome-extensions enable lockkeys@vaina.lt
		gnome-extensions enable theme-switcher@fthx
		gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
		
		if [[ -f "$CONFIG/.LAPTOP" ]]
		then
			gnome-extensions enable x11gestures@joseexposito.github.io
		fi
	
	# Tweaking Extensions

		gsettings --schemadir $EXTENSIONS/lockkeys@vaina.lt/schemas/  set org.gnome.shell.extensions.lockkeys style 'capslock'	
		
		gsettings --schemadir $EXTENSIONS/date-menu-formatter@marcinjakubowski.github.com/schemas/ set org.gnome.shell.extensions.date-menu-formatter pattern 'EEEE, MMMM dd | hh : mm a'
		
		if [[ -f "$CONFIG/.LAPTOP" ]]
		then
			gsettings --schemadir $EXTENSIONS/x11gestures@joseexposito.github.io/schemas/  set org.gnome.shell.extensions.x11gestures swipe-fingers 4
		fi
		
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection theme true
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection activities-button false
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection events-button false
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection world-clock false
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection weather false
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection window-demands-attention-focus true
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection clock-menu-position 1
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection clock-menu-position-offset 8
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection notification-banner-position 2
		gsettings --schemadir $EXTENSIONS/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection osd-position 5
		
		gsettings set org.gnome.shell.extensions.ding show-home false
		gsettings set org.gnome.shell.extensions.ding show-volumes true
		gsettings set org.gnome.shell.extensions.ding show-trash true
		gsettings set org.gnome.shell.extensions.ding start-corner 'top-left'
		
		touch $CONFIG/.BaseSystem2
		killall -3 gnome-shell
fi

if [[ -f "$CONFIG/.DEFAULT" ]]
then
    sudo nala install code p7zip-rar -y
    sudo flatpak install flathub com.github.carlos157oliveira.Calculus org.onlyoffice.desktopeditors com.github.eneshecan.WhatsAppForLinux -y
    wget https://raw.githubusercontent.com/puneetsl/lotion/master/setup.sh
    chmod +x ./setup.sh
    ./setup.sh native
    rm ./setup.sh
else
    
    # Optional Apps
		touch .AdditionalAPPS.sh
		#APT
		if zenity --question --title='Ubuntu Spinner' --text='Install VS CODE ?'
		then
			echo "sudo nala install code -y" >> .AdditionalAPPS.sh
		fi

		if zenity --question --title='Ubuntu Spinner' --text='Install Android Studio ?'
		then
			echo "sudo nala install android-studio -y" >> .AdditionalAPPS.sh
		fi

		if zenity --question --title='Ubuntu Spinner' --text='Install PyCharm (Community) ?'
		then
			echo "sudo nala install pycharm-community -y" >> .AdditionalAPPS.sh
		fi

		if zenity --question --title='Ubuntu Spinner' --text='Install DataSpell ?'
		then
			echo "sudo nala install dataspell -y" >> .AdditionalAPPS.sh
		fi

		if zenity --question --title='Ubuntu Spinner' --text='Install IntelliJ IDEA (Community) ?'
		then
			echo "sudo nala install intellij-idea-community -y" >> .AdditionalAPPS.sh
		fi
		
		# Flatpak
		if zenity --question --title='Ubuntu Spinner' --text='Install OnlyOffice ?'
		then
			echo "sudo flatpak install flathub org.onlyoffice.desktopeditors -y" >> .AdditionalAPPS.sh
		fi
		
		if zenity --question --title='Ubuntu Spinner' --text='Install Calculus ?'
		then
			echo "sudo flatpak install flathub com.github.carlos157oliveira.Calculus -y" >> .AdditionalAPPS.sh
		fi
		
		if zenity --question --title='myPopConfig' --text='Install WhatsApp for Linux (Unofficial) ?'
		then
			echo "sudo flatpak install flathub com.github.eneshecan.WhatsAppForLinux -y" >> .AdditionalAPPS.sh
		fi
		
		# Source Build
		if zenity --question --title='Ubuntu Spinner' --text='Install Notion (Unofficial) ?'
		then
			echo "sudo apt install p7zip-rar -y" >> .AdditionalAPPS.sh
			echo "wget https://raw.githubusercontent.com/puneetsl/lotion/master/setup.sh" >> .AdditionalAPPS.sh
			echo "chmod +x ./setup.sh" >> .AdditionalAPPS.sh
			echo "./setup.sh native" >> .AdditionalAPPS.sh
			echo "rm ./setup.sh" >> .AdditionalAPPS.sh
		fi

    	chmod +x .AdditionalAPPS.sh
    	./.AdditionalAPPS.sh
	rm ./.AdditionalAPPS.sh

fi


dconf write /org/gnome/shell/favorite-apps "['firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Software.desktop', 'vlc.desktop', 'code.desktop', 'android-studio.desktop', 'pycharm-community.desktop', 'dataspell.desktop', 'intellij-idea-community.desktop', 'Notion_native.desktop', 'org.onlyoffice.desktopeditors.desktop', 'com.github.eneshecan.WhatsAppForLinux.desktop']"
