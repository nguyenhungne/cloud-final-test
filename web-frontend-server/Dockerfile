FROM nginx:stable

# Copy Nginx configuration
COPY conf.default /etc/nginx/conf.d/default.conf

# Copy HTML files
COPY html/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
