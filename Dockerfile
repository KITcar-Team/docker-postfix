FROM tozd/runit

EXPOSE 25/tcp 465/tcp 587/tcp

VOLUME /var/log/postfix
VOLUME /var/spool/postfix

ENV MAILNAME "kitcar-team.de"
ENV MY_NETWORKS "172.17.0.0/16 172.18.0.0/16 172.19.0.0/16 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
ENV MY_DESTINATION "kitcar-team.de, v22017012330143187.hotsrv.de, localhost.hotsrv.de, localhost"
ENV ROOT_ALIAS admin@example.com

# /etc/aliases should be available at postfix installation.
COPY ./etc/aliases /etc/aliases

# We disable IPv6 for now, IPv6 is available in Docker even if the host does not have IPv6 connectivity.
RUN apt-get update -q -q && \
 echo postfix postfix/main_mailer_type string "'Internet Site'" | debconf-set-selections && \
 echo postfix postfix/mynetworks string "172.17.0.0/16 172.18.0.0/16 172.19.0.0/16 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128" | debconf-set-selections && \
 echo postfix postfix/mailname string kitcar-team.de | debconf-set-selections && \
 apt-get --yes --force-yes install postfix && \
 postconf -e mydestination="kitcar-team.de, v22017012330143187.hotsrv.de, localhost.hotsrv.de, localhost" && \
 postconf -e smtpd_banner='$myhostname ESMTP $mail_name' && \
 postconf -# myhostname && \
 postconf -e inet_protocols=ipv4 && \
 apt-get --yes --force-yes --no-install-recommends install rsyslog && \
 sed -i 's/\/var\/log\/mail/\/var\/log\/postfix\/mail/' /etc/rsyslog.d/50-default.conf

COPY ./etc /etc
