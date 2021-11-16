FROM alpine:3.11 AS BASE
#install python
RUN apk add --update python2 && ln -sf /usr/bin/python
RUN python2 -m ensurepip
RUN pip install --upgrade pip setuptools


#install nodejs/npm
RUN apk add --update nodejs npm 
RUN apk add --update npm 

#DEP -package.json
WORKDIR /app
COPY ./project/flask-app/package.json ./package.json
RUN npm install

#build 
COPY ./project/flask-app/webpack.config.js ./webpack.config.js
COPY ./project/flask-app/static/ ./static/
COPY ./project/flask-app/templates/ ./templates/
COPY ./project/flask-app/.babelrc ./.babelrc


RUN npm run build 

#add DEP to pytohn flask
COPY ./project/flask-app/requirements.txt ./requirements.txt
RUN pip install --target=/app -r requirements.txt

#multi stage
FROM python:2.7-alpine
COPY --from=BASE /app /app
WORKDIR /app

COPY ./project/flask-app/app.py ./app.py
CMD ["python","./app.py"]


