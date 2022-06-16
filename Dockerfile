FROM centos:7

#WORKDIR /tmp

# Run as root
USER 0

ENV APP_ROOT=/opt/app-root
ENV HOME=${APP_ROOT}

COPY bin/ ${APP_ROOT}/bin/

# Add our init script
#ADD startsiab.sh /opt/startsiab.sh
# Add our logo
ADD siab.logo.txt /opt/siab.logo.txt
# Fix up the Reverse coloring
ADD black-on-white.css /usr/share/shellinabox/black-on-white.css
# Add nano syntax highlighting for Dockerfiles
ADD dockerfile.nanorc /usr/share/nano/dockerfile.nanorc
# Add nano syntax highlighting for JS
ADD javascript.nanorc /usr/share/nano/javascript.nanorc
# Enable nano syntax highlighting
ADD nanorc /tmp/nanorc

# Install EPEL
# Install our developer tools (tmux, ansible, nano, vim, bash-completion, wget)
# Free up some space
# Install oc
# Add our developer user
# Bring in nano's user config
# Give nano's user config the correct ownership
# Set the default password for our 'developer' user
# Randomize root's password
# Be sure to remove login's lock file
RUN echo "" && \
    cat /opt/siab.logo.txt && \
    echo "=== Installing EPEL ===" && \
    yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-14.noarch.rpm && \
    echo "\n=== Installing developer tools ===" && \
    yum install -y jq vim screen which hostname passwd tmux nano wget git bash-completion openssl shellinabox util-linux expect --enablerepo=epel && \
    yum clean all && \
    cd /tmp/ && \
    echo "\n=== Installing oc ===" && \
    wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz && \
    ls -lah /tmp/ && \
    echo "\n=== Untar'ing 'oc' ===" && \
    tar zxvf /tmp/openshift-client-linux.tar.gz && \
    echo "\n=== Copying 'oc' ===" && \
    mv -v /tmp/oc /usr/local/bin && \
    echo "\n=== Installing 'developer' user ===" && \
    useradd -u 1001 developer -m && \
    mkdir -pv /home/developer/bin /home/developer/tmp && \
    echo "\n=== Bringing in nano's user config ===" && \
    mv -v /tmp/nanorc /home/developer/.nanorc && \
    echo "\n=== Giving nano's user config the correct ownership ===" && \
    chown -R 1001:1001 /home/developer && \
    echo "\n=== Setting the default password for our 'developer' user ===" && \
    ( echo "developer" | passwd developer --stdin ) && \
    echo "\n=== Randomizing root's password ===" && \
    ( cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 128 | head -n 1 | passwd root --stdin ) && \
    echo "\n=== Removing login's lock file ===" && \
    rm -f /var/run/nologin && \
    echo "\n*** Done building siab container ***" && \
    cat /opt/siab.logo.txt

### Setup user for build execution and application runtime
#ENV JAVA_HOME=/usr/lib/jvm/jre-openjdk
#ENV M2_HOME=/opt/maven
#ENV MAVEN_HOME=/opt/maven
ENV APP_ROOT=/opt/app-root
#ENV OPENSHIFT_CLI=${APP_ROOT}/bin/oc
#Update PATH
#ENV PATH=${APP_ROOT}/bin:${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${OPENSHIFT_CLI}:${PATH}
ENV PATH=${APP_ROOT}/bin:${PATH}

### Update Permissions and Execute any additional scripts or commands
RUN mkdir -p ${APP_ROOT}/.kube && \
    mkdir -p ${APP_ROOT}/data && \
	#fix-permissions ${APP_ROOT}/.kube -P && \
    #fix-permissions ${APP_ROOT}/data -P && \
    #fix-permissions ${APP_ROOT} -P && \
    chown -R developer:0 ${APP_ROOT} && \
    chmod -R u+x ${APP_ROOT}/bin && \
    #chmod +x ${APP_ROOT}/bin/uid_entrypoint.sh && \
    #chmod +x ${APP_ROOT}/entrypoint.sh
    chmod -R g=u ${APP_ROOT} /etc/passwd
    #Add any scripts or other commands here
    #${APP_ROOT}/bin/add-cert.sh ${APP_ROOT}/Cert.cer

# shellinabox will listen on 8080
EXPOSE 8080

# Run as developer
USER developer

# Workdir
WORKDIR ${APP_ROOT}

ENTRYPOINT [ "./bin/uid_entrypoint.sh" ]
CMD ./bin/startsiab.sh
