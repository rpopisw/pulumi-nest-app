FROM node:16.18.1 AS builder

WORKDIR /build
COPY package.json ./
COPY . .

RUN npm install
RUN npm run build

FROM node:16.18.1

WORKDIR /opt

RUN apt-get update && apt-get -y install wget libaio1 unzip

# RUN wget https://download.oracle.com/otn_software/linux/instantclient/218000/instantclient-basic-linux.x64-21.8.0.0.0dbru.zip && \ 
#   mkdir -p /opt/oracle/ && \
#   unzip instantclient-basic-linux.x64-21.8.0.0.0dbru.zip -d /opt/oracle/

# RUN export PATH=/usr/local/bin:/usr/bin:/sbin:$PATH

# RUN echo /opt/oracle/instantclient_21_8 > /etc/ld.so.conf.d/oracle-instantclient.conf && \ 
#   /sbin/ldconfig

# RUN export LD_LIBRARY_PATH=/opt/oracle/instantclient_21_8:$LD_LIBRARY_PATH 

# RUN export PATH=/opt/oracle/instantclient_21_8:$PATH

WORKDIR /app
COPY --from=builder /build/dist ./dist
COPY --from=builder /build/package.json .
COPY --from=builder /build/node_modules ./node_modules

CMD ["npm","run", "start:prod"]