{ config, pkgs, lib, ... }: {
  services.samba.extraConfig = ''
    min protocol = SMB3
    vfs objects = acl_xattr catia fruit streams_xattr
    fruit:nfs_aces = no
    inherit permissions = yes
    fruit:posix_rename = yes
    fruit:resource = xattr
    fruit:model = MacSamba
    fruit:veto_appledouble = no
    fruit:wipe_intentionally_left_blank_rfork = yes 
    fruit:delete_empty_adfiles = yes 
    fruit:metadata = stream
  '';

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.publish.enable = true;
  services.avahi.extraServiceFiles.smb = ''
    <?xml version="1.0" standalone='no'?>
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name replace-wildcards="yes">%h</name>
      <service>
        <type>_smb._tcp</type>
        <port>445</port>
        <host-name>ds9.kangaroo-galaxy.ts.net</host-name>
      </service>
      <service>
        <type>_device-info._tcp</type>
        <port>0</port>
        <txt-record>model=MacPro7,1@ECOLOR=226,226,224</txt-record>
      </service>
      <service>
        <type>_adisk._tcp</type>
        <txt-record>sys=waMa=0,adVF=0x100</txt-record>
        <txt-record>dk0=adVN=TimeMachine,adVF=0x82</txt-record>
        <host-name>ds9.kangaroo-galaxy.ts.net</host-name>
      </service>
    </service-group>
  '';

  ragon.services = {
    samba.enable = true;
    samba.shares = {
      TimeMachine = {
        path = "/backups/DaedalusTimeMachine";
        comment = "DaedalusTimeMachine";
        "write list" = "@wheel";
        "read only" = "no";
        "writable" = "yes";
        "browseable" = "yes";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = "2050G";
        "vfs objects" = "acl_xattr fruit streams_xattr";
        "inherit acls" = "yes";
      };
      data = {
        path = "/data";
        comment = "some data for the people";
        "write list" = "@wheel";
      };
    };
  };

}
