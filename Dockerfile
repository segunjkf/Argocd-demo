FROM nginx

RUN echo "<h1>This is a Demo for ArgoCD-Demo</h1>" > /usr/share/nginx/html/index.html

EXPOSE 80

