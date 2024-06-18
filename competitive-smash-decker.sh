#!/bin/bash

clear

echo -e "Competitive Smash Decker - script by The Outcaster\n"

title="Competitive Smash Decker"

# Removes unhelpful GTK warnings
zen_nospam() {
  zenity 2> >(grep -v 'Gtk' >&2) "$@"
}

# zenity functions
error() {
	e=$1
	zen_nospam --error --title="$title" --width=500 --height=100 --text "$1"
}

info() {
	i=$1
	zen_nospam --info --title "$title" --width 400 --height 75 --text "$1"
}

progress_bar() {
	t=$1
	zen_nospam --title "$title" --text "$1" --progress --auto-close --auto-kill --width=300 --height=100

	if [ "$?" != 0 ]; then
		echo -e "\nUser canceled.\n"
	fi
}

question() {
	q=$1
	zen_nospam --question --title="$title" --width=300 height=200 --text="$1"
}

text_info() {
	title=$1
	filename=$2
	zen_nospam --text-info --width=500 --height=500 --title="$1" --filename="$2"
}

# menus
main_menu() {
	zen_nospam --width 700 --height 350 --list --radiolist --multiple --title "$title"\
	--column ""\
	--column "Option"\
	--column="Description"\
	FALSE Remix "Smash 64 Remix with additional characters"\
	FALSE Slippi "Super Smash Bros. Melee with online multiplayer"\
	FALSE Project+ "A continuation of Project M that turns SSBB into a more competitive game"\
	FALSE HDR "Smash Ultimate with competitive mechanics"\
	FALSE Overclock "Overclock your GCC adapter (root password required)"\
	TRUE Exit "Exit this script"
}

smash64_remix_menu() {
	zen_nospam --width 700 --height 350 --list --radiolist --multiple --title "$title"\
	--column ""\
	--column "Option"\
	--column="Description"\
	FALSE Download "Download Smash 64 Remix patch and patch the ROM"\
	TRUE Exit "Exit this submenu"
}

slippi_menu() {
	zen_nospam --width 700 --height 350 --list --radiolist --multiple --title "$title"\
	--column ""\
	--column "Option"\
	--column="Description"\
	FALSE Download "Download or update the Slippi Launcher"\
	FALSE Launch_Launcher "Launch Slippi Launcher"\
	FALSE Slippi "Configure or play Slippi (without launcher)"\
	TRUE Exit "Exit this submenu"
}

projectplus_menu() {
	zen_nospam --width 700 --height 350 --list --radiolist --multiple --title "$title"\
	--column ""\
	--column "Option"\
	--column="Description"\
	FALSE Download "Download or update Project+"\
	FALSE Configure "Configure or play Project+"\
	False Changelog "View changelog (will open your web browser)"\
	TRUE Exit "Exit this submenu"
}

hdr_menu() {
	zen_nospam --width 700 --height 350 --list --radiolist --multiple --title "$title"\
	--column ""\
	--column "Option"\
	--column="Description"\
	FALSE Download "Download or update the HDR Launcher"\
	FALSE Resources "Get save data, legacy discovery, latency slider, and configure online multiplayer"\
	TRUE Exit "Exit this submenu"
}

# roms
smash64_ROM=$HOME/Emulation/roms/n64/smash64.z64
melee_ROM=$HOME/Emulation/roms/gamecube/ssbm.iso
brawl_ROM=$HOME/Emulation/roms/wii/ssbb.iso
ultimate_ROM=$HOME/Emulation/roms/switch/ssbu.nsp

# executables
slippi_launcher=$HOME/Applications/Slippi-Launcher/Slippi-Launcher.AppImage
slippi=$HOME/.config/Slippi\ Launcher/netplay/Slippi_Online-x86_64.AppImage
project_plus=$HOME/Applications/ProjectPlus/Faster_Project_Plus-x86-64.AppImage

# Check if GitHub is reachable
if ! curl -Is https://github.com | head -1 | grep 200 > /dev/null
then
    echo "GitHub appears to be unreachable, you may not be connected to the Internet."
    exit 1
fi

cd $HOME
mkdir -p Emulation
mkdir -p Emulation/roms
mkdir -p Emulation/roms/n64
mkdir -p Emulation/roms/gamecube
mkdir -p Emulation/roms/wii
mkdir -p Emulation/roms/switch

mkdir -p Applications
cd Applications

# Main menu
while true; do
Choice=$(main_menu)
	if [ $? -eq 1 ] || [ "$Choice" == "Exit" ]; then
		
		echo Goodbye!
		exit

	elif [ "$Choice" == "Remix" ]; then
		
		while true; do
		Choice=$(smash64_remix_menu)
			if [ $? -eq 1 ] || [ "$Choice" == "Exit" ]; then
				break
			
			elif [ "$Choice" == "Download" ]; then
				#check to see if ROM exists
				if ! [ -f $smash64_ROM ]; then
					error "ROM not found. Please put it in $HOME/Emulation/roms/n64/ and name it to smash64.z64"
				else
					curl -L $(curl -s https://api.github.com/repos/JSsixtyfour/smashremix/releases/latest | grep "browser_download_url" | cut -d '"' -f 4) -o smashremix.zip
					unzip -o smashremix.zip
					chmod +x smashremix*/.ezpatch/bin/linux/ucon64 smashremix*/.ezpatch/bin/linux/xdelta3 smashremix*/.ezpatch/scripts/unix.sh
					bash smashremix*/.ezpatch/scripts/unix.sh $smash64_ROM
					mv smashremix*/output/smashremix*.z64 $HOME/Emulation/roms/n64/
					info "Smash 64 Remix ROM has been moved over to $HOME/Emulation/roms/n64/."
					rm smashremix.zip
				fi
			fi
		done
	
	elif [ "$Choice" == "Slippi" ]; then
		
		while true; do
		Choice=$(slippi_menu)
		
			if [ $? -eq 1 ] || [ "$Choice" == "Exit" ]; then
				break
			
			elif [ "$Choice" == "Download" ]; then
				mkdir -p Slippi-Launcher
				
				DOWNLOAD_URL=$(curl -s https://api.github.com/repos/project-slippi/slippi-launcher/releases/latest \
        				| grep "browser_download_url" \
			        	| grep AppImage \
			        	| cut -d '"' -f 4)
				curl -L "$DOWNLOAD_URL" -o $slippi_launcher
				
				chmod +x $slippi_launcher
				info "Slippi Launcher downloaded/updated!"
			
			elif [ "$Choice" == "Launch_Launcher" ]; then
				if ! [ -f $slippi_launcher ]; then
					error "Slippi Launcher AppImage not found."
				else
					exec $slippi_launcher
				fi
			
			elif [ "$Choice" == "Slippi" ]; then
				if ! [ -f "$slippi" ]; then
					error "Slippi AppImage not found."
				else
					exec "$slippi"
				fi
			fi
		done

	elif [ "$Choice" == "Project+" ]; then
		
		while true; do
		Choice=$(projectplus_menu)
		
			if [ $? -eq 1 ] || [ "$Choice" == "Exit" ]; then
				break
					
			elif [ "$Choice" == "Download" ]; then
				mkdir -p ProjectPlus
				cd ProjectPlus
				
				# remove files if they have been previously downloaded
				rm -rf *
				
				(
				echo "33"
				echo "# Downloading files..."
				curl -L https://api.github.com/repos/jlambert360/FPM-AppImage/releases/latest | grep "browser_download_url" | cut -d : -f 2,3 | tr -d \" | wget -qi -
				
				echo "66"
				echo "# Extracting..."
				tar -xf Launcher.tar.gz
				tar -xf sd.tar.gz
				
				chmod +x $project_plus
				
				echo "90"
				echo "# Cleaning up..."
				rm Launcher.tar.gz sd.tar.gz
				) | progress_bar ""
				
				info "Project+ downloaded/updated!"
				
				cd $HOME/Applications
			
			elif [ "$Choice" == "Configure" ]; then
				if ! [ -f $project_plus ]; then
					error "Project+ AppImage not found."
				else
					exec $project_plus
				fi
			
			elif [ "$Choice" == "Changelog" ]; then
				xdg-open https://projectplusgame.com/changes
			fi
		done
	
	elif [ "$Choice" == "HDR" ]; then
		
		while true; do
		Choice=$(hdr_menu)
			if [ $? -eq 1 ] || [ "$Choice" == "Exit" ]; then
				break
			
			elif [ "$Choice" == "Download" ]; then
				mkdir -p HDR

				DOWNLOAD_URL=$(curl -s https://api.github.com/repos/techyCoder81/hdr-launcher-react/releases/latest \
					| grep "browser_download_url" \
					| grep AppImage \
					| cut -d '"' -f 4)
				curl -L "$DOWNLOAD_URL" -o HDR/HDRLauncher.AppImage

				chmod +x HDR/HDRLauncher.AppImage
					
				info "HDR Launcher downloaded!"

			elif [ "$Choice" == "Resources" ]; then
				if ! [ -d $HOME/.local/share/yuzu/sdmc/ultimate/arcropolis ]; then
					error "Arcropolis folder not found, please run Smash Ultimate at least once after HDR is installed to generate the config files/folders."
					break
				fi

				(
				echo "20"
				echo "# Adding legacy discovery file..."
				sleep 1
				touch legacy_discovery
				mv legacy_discovery $HOME/.local/share/yuzu/sdmc/ultimate/arcropolis/config/*/*/

				echo "50"
				echo "# Downloading save data..."
				sleep 1
				wget https://github.com/the-outcaster/competitive-smash-decker/raw/main/100_save_data-1.zip
				unzip -o -q 100_save_data-1.zip -d $HOME/.local/share/yuzu/nand/user/save/*/*/01006A800016E000/
				rm 100_save_data-1.zip

				echo "70"
				echo "# Downloading latency slider plugin..."
				sleep 1
				DOWNLOAD_URL=$(curl -s https://api.github.com/repos/saad-script/local-latency-slider/releases/latest \
					| grep "browser_download_url" \
					| grep .nro \
					| cut -d '"' -f 4)
				curl -L "$DOWNLOAD_URL" -o $HOME/.local/share/yuzu/sdmc/atmosphere/contents/01006A800016E000/romfs/skyline/plugins/liblocal_latency_slider.nro

				echo "90"
				echo "# Configurating multiplayer lobby settings..."
				sleep 1
				sed -i 's/web_api_url\\default=true/web_api_url\\default=false/' $HOME/.config/yuzu/qt-config.ini
				sed -i 's|web_api_url=https:/api.yuzu-emu.org|web_api_url=api.ynet-fun.xyz|' $HOME/.config/yuzu/qt-config.ini
				sleep 1

				if ( question "Would you like to download a pre-configured Steam Deck template for controls and graphics settings?" ); then
				yes |
					wget https://raw.githubusercontent.com/the-outcaster/competitive-smash-decker/main/qt-config.ini
					mv qtconfig.ini $HOME/.config/yuzu/
				else
					break
				fi
				) | progress_bar ""

				info "HDR resources successfully downloaded and installed!"
			fi
		done
	
	elif [ "$Choice" == "Overclock" ]; then
		curl -L https://raw.githubusercontent.com/the-outcaster/gcadapter-oc-kmod-deck/main/install_gcadapter-oc-kmod.sh | sh
	fi
done
