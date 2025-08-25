vgnpc-plasmodium-spp
====================

This repository contains preset configurations and scripts to automatically prepare
vivaxGEN NGS-Pipeline environment directory for WGS analysis of Plasmodium species.


Installation
------------

To setup a base environment directory and install the preset configuration,
use the following stepsi (assuming PvP01_v2 reference genome):

#. activate a plain (base) NGS-Pipeline environment::

     $ [NGS_PIPELINE_INSTALL_DIR]/bin/activate

#. generate a base enviroment directory, for example: ``/data/WGS/Pv/PvP01_v2``::

     $ ngs-pl setup-base-directory /data/WGS/Pv/PvP01_v2

   .. tip::
      To easily identify and differentiate between several base enviroment directory,
      it is recommended to use the reference genome name as part of the directory
      name

#. exit from the current enviroment and activate the new enviroment with the base
   enviroment directory::

     $ exit
     $ /data/WGS/Pv/PvP01_v2/activate

#. run the installation command for the intended settings, ie. for Plasmodium vivax PvP01_v2
   (for other genomes, see Configuration Options section below)::

     $ bash <(curl -L https://raw.githubusercontent.com/vivaxgen/vgnpc-plasmodium-spp/main/Pvivax/PvP01_v2/setup.sh)

Once installation process is completed successfully, the settings is ready to be used.


Configuration Options
---------------------

The following are the installation commands for various reference genomes:

- Plasmodium vivax PvP01_v2::

    $ bash <(curl -L https://raw.githubusercontent.com/vivaxgen/vgnpc-plasmodium-spp/main/Pvivax/PvP01_v2/setup.sh)

- Plasmodium falciparum Pf3D7_v3::

    $ bash <(curl -L https://raw.githubusercontent.com/vivaxgen/vgnpc-plasmodium-spp/main/Pfalciparum/Pf3D7_v3/setup.sh)

- Plasmodium malariae PmUG01_v1::

    $ bash <(curl -L https://raw.githubusercontent.com/vivaxgen/vgnpc-plasmodium-spp/main/Pmalariae/PmUG01_v1/setup.sh)


