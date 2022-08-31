#--- Variable from script to send email with the blacklist found

email_notify='<?php
$to = "admins@domain.com";
$subject = "[!!!] Blacklist triggered your server [!!!]";
$headers = "From: blacklistchecker@domain.com" . "\r\n" .
    "Reply-To: admins@domain.com" . "\r\n" .
    "X-Mailer: PHP/" . phpversion();
$message = file_get_contents("/tmp/blacklist.txt");
mail($to, $subject, $message, $headers);
'

blacklists='access.redhawk.org
all.s5h.net
b.barracudacentral.org
bl.spamcop.net
bl.technovision.dk
bl.tiopan.com
blackholes.five-ten-sg.com
blackholes.wirehub.net
blacklist.sci.kun.nl
blacklist.woody.ch
block.dnsbl.sorbs.net
blocked.hilli.dk
bogons.cymru.com
cart00ney.surriel.com
cblless.anti-spam.org.cn
cdl.anti-spam.org.cn
combined.abuse.ch
db.wpbl.info
dev.null.dk
dialup.blacklist.jippg.org
dialups.mail-abuse.org
dialups.visi.com
dnsbl-1.uceprotect.net
dnsbl-2.uceprotect.net
dnsbl-3.uceprotect.net
dnsbl.abuse.ch
dnsbl.anticaptcha.net
dnsbl.antispam.or.id
dnsbl.cyberlogic.net
dnsbl.dronebl.org
dnsbl.inps.de
dnsbl.kempt.net
dnsbl.njabl.org
dnsbl.sorbs.net
dnsbl.tornevall.org
drone.abuse.ch
duinv.aupads.org
dul.dnsbl.sorbs.net
dul.ru
dyna.spamrats.com
dynip.rothen.com
escalations.dnsbl.sorbs.net
exitnodes.tor.dnsbl.sectoor.de
hil.habeas.com
http.dnsbl.sorbs.net
intruders.docs.uu.se
ips.backscatterer.org
ix.dnsbl.manitu.net
korea.services.net
mail-abuse.blacklist.jippg.org
misc.dnsbl.sorbs.net
msgid.bl.gweep.ca
new.dnsbl.sorbs.net
no-more-funn.moensted.dk
noptr.spamrats.com
old.dnsbl.sorbs.net
orvedb.aupads.org
proxy.bl.gweep.ca
psbl.surriel.com
pss.spambusters.org.ar
rbl.schulte.org
rbl.snark.net
recent.dnsbl.sorbs.net
relays.bl.gweep.ca
relays.bl.kundenserver.de
relays.mail-abuse.org
relays.nether.net
rsbl.aupads.org
short.rbl.jp
singular.ttk.pte.hu
smtp.dnsbl.sorbs.net
socks.dnsbl.sorbs.net
spam.abuse.ch
spam.dnsbl.sorbs.net
spam.olsentech.net
spam.spamrats.com
spambot.bls.digibase.ca
spamguard.leadmon.net
spamrbl.imp.ch
spamsources.fabel.dk
tor.dnsbl.sectoor.de
ubl.lashback.com
ubl.unsubscore.com
virbl.bit.nl
virus.rbl.jp
web.dnsbl.sorbs.net
whois.rfc-ignorant.org
wormrbl.imp.ch
zombie.dnsbl.sorbs.net
'
#--- Main script to loop through all the blacklist
main() {
  reverse=$(echo $1 |
  sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\4.\3.\2.\1~p")
  reverse_dns=$(dig +short -x $1)
  echo $2
#  echo $1 name ${reverse_dns:----}
  for bl in ${blacklists}; do

      printf $(env tz=utc date "+%y-%m-%d_%h:%m:%s_%z")
      printf "%-40s" " ${reverse}.${bl}."
      listed="$(dig +short -t a ${reverse}.${bl}.)"

      if [[ $listed ]]; then

        if [[ $listed == *"timed out"* ]]; then

          echo "[timed out]" | cecho YELLOW
        else

          echo "[blacklisted] (${listed})" | cecho LRED
          echo -e "Server: $2\nIP:$1\nBlacklist: ${bl}\nTimestamp checked: `env tz=utc date "+%y-%m-%d_%h:%m:%s"`\n------------------\n\n" > /tmp/blacklist.txt
        fi
      else

          echo "[not listed]" | cecho LGREEN
      fi
  done
}


#--- Colored echo
cecho(){
  LGREEN="\033[1;32m"
  LRED="\033[1;31m"
  YELLOW="\033[1;33m"
  NORMAL="\033[m"
  color=\$${1:-NORMAL}
  echo -ne "$(eval echo ${color})"
  cat
  echo -ne "${NORMAL}"
}

#-- Loop between ip addresses
for i in 127.0.0.1 192.168.0.1;
do
echo
        main $i "Server type"
done

#-- Notifying for any blacklist
if ! [[ -f /tmp/blacklist.txt ]]; then
        echo No blacklist found
else
        echo $email_notify > /tmp/email_notify.php
        php /tmp/email_notify.php
        rm -f /tmp/email_notify.php /tmp/blacklist.txt
        echo Blacklist found, sending email
fi
