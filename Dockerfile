from raspbian/systemd:latest
RUN echo "deb http://legacy.raspbian.org/raspbian stretch main contrib non-free rpi" > /etc/apt/sources.list
workdir /home/chronos
run apt-get update -y && apt-get install python2.7 python-pip cron sqlite3 nginx libssl-dev vim -y
run useradd pi
run mkdir -p /home/pi/chronos_db
run CFLAGS="-I/usr/include/openssl" && LDFLAGS="-L/usr/lib/arm-linux-gnueabihf" && UWSGI_PROFILE_OVERRIDE=ssl=true && pip install -I --no-binary=:all: --no-cache-dir uwsgi==2.0.20
run pip install flask pyserial pymodbus APScheduler==3.6.3
run pip install --upgrade setuptools
run pip install sqlalchemy python-socketio==0.4.1 socketIO_client six==1.15.0
run pip install gevent
run pip install python-engineio==3.11.2 python-socketio==4.4.0
run pip install gevent-websocket


# Try not to touch the above since installing gvenet takes too long
# Install python3 and run the virtual serial emulators
run apt-get install python3 python3-pip socat -y

copy . .
copy chronos.sql /home/pi/chronos_db/
run python setup.py install
run rm /etc/nginx/sites-enabled/default
run ln -s /etc/nginx/sites-enabled/chronos_conf /etc/nginx/sites-enabled/default
#run /usr/local/bin/uwsgi --ini /etc/uwsgi/apps-enabled/socketio_server.ini --pidfile /var/run/uwsgi/uwsgi-socketio.pid --daemonize /var/log/uwsgi/uwsgi-socketio.log
run chmod +x entrypoint.sh

entrypoint [ "./entrypoint.sh" ]
