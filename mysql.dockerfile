FROM ubuntu/mysql     

# Set locale to UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Install essential packages.   
RUN apt-get update -y && \      
    apt-get upgrade -y && \     
    apt-get install sudo nano openssh-server -y && \
    apt-get install locales -y && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

EXPOSE 3306