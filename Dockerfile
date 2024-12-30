FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php7.4 \
    php7.4-mysql \
    php7.4-soap \
    php7.4-intl \
    php7.4-zip \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-curl \
    php7.4-xml \
    php7.4-json \
    php7.4-opcache \
    php7.4-pdo \
    php7.4-mysql \
    wget \
    unzip \
    mysql-client \
    tzdata && \
    ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    a2enmod rewrite

# Download and extract Moodle
RUN wget https://download.moodle.org/download.php/direct/stable39/moodle-latest-39.tgz -O /tmp/moodle.tgz && \
    tar -zxvf /tmp/moodle.tgz -C /var/www && \
    rm /tmp/moodle.tgz

# Set permissions
RUN chown -R www-data:www-data /var/www/moodle && \
    mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www/moodledata && \
    chmod -R 777 /var/www/moodledata

# Configure Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Configure Apache to serve Moodle
COPY moodle.conf /etc/apache2/conf-available/moodle.conf
RUN a2enconf moodle

COPY moodle-config.php /var/www/moodle/config.php

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
