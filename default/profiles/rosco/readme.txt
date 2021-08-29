NOTE:
Files in halyard: ~/.hal/default/profiles/rosco/ goes to Rosco: /opt/rosco/config/ directory.
    Hence ~/.hal/default/profiles/rosco/packerTempates/* => /opt/rosco/config/packerTempates/*
Yml files in halyard: ~/.hal/default/profiles/rosco[-<anytext>].yml goes to Rosco: /opt/spinnaker/config/ directory. 


INSTRUCTION:
- Copy packerTemplates/ directory to Halyard:~/.hal/default/profiles/rosco/
  This directory includes packer templates in .json format and supporting scripts

- Copy rosco-packer.yml file to Halyard:~/.hal/default/profiles/
  This is to load custom images in Spinnaker UI's Bake stage

- Edit the file Halyard:~/.hal/default/service-settings/rosco.yml 
  ```
  env:
    SPRING_PROFILES_ACTIVE: "overrides,packer,local"
  ```
  This activates `packer` profile. The profile name comes from the file ~/.hal/default/profiles/rosco-packer.yml.
  Note: The profile value is from the name <service>-<profile>.yml in profiles directory. Make sure the profile local comes as last item.
