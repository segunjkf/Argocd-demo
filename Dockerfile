FROM nginx

RUN echo "<h1>This is for ArgoCD-Demo. The Delearative Approach</h1>" > /usr/share/nginx/html/index.html

EXPOSE 80

