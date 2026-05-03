FROM fedora:40 as extractor
RUN mkdir -p /rootfs
COPY --from=ghcr.io/mbuccarello/cc:latest / /rootfs/
COPY payload/jdk.tar.gz /

RUN mkdir -p /rootfs/usr/lib/jvm/java-21-openjdk && tar -xzf /jdk.tar.gz -C /rootfs/usr/lib/jvm/java-21-openjdk

# Regenerate library cache
RUN ldconfig -r /rootfs
RUN ln -sf /usr/lib/jvm/java-21-openjdk/bin/java /rootfs/usr/bin/java
RUN ln -sf /usr/lib/jvm/java-21-openjdk/bin/keytool /rootfs/usr/bin/keytool

FROM scratch
COPY --from=extractor /rootfs /
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk
ENV PATH=\$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
ENTRYPOINT ["/usr/bin/java"]
CMD ["-version"]
