# US hub of Shopshops

## Things you may want to cover:

* Ruby version
2.3.1

* Rails version
5.1.5

* Database
PostgresSQL

* 运行test
rspec spec/

* API文档
/docs

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## How to set up local environment (tutorial for Ubuntu & Mac OS):
* install RVM:
    * i.e. Ruby version manager (Strongly recommended) 
    [Follow this tutorial to install it](https://github.com/rvm/rvm)
    

* install ruby version 2.3.1:
    * RVM makes your life easier, simply run command `rvm install 2.3.1`
    * if you failed to install it, try running the following commands then retry it:
    ```
     rvmsudo rvm cleanup all
     rvm get master
    ```
 
* install node.js:
    * simply run the following commands
    ```
    sudo apt-get update
    sudo apt-get install nodejs
    ```
        
* install PostgreSQL (psql):
    * simply run the following commands
    ```
    sudo apt-get update
    sudo apt-get install postgresql postgresql-contrib
    ```
        
* install bundler and rails:
    * simply run following commands
    ```
    gem install bundler
    gem install rails
    bundle install
    ```
 * install Redis
    * run the following commands:
    ```
    sudo apt-get update
    sudo apt-get install redis-server
    ```
 
 * create your local databases:
   * run `sudo -i -u postgres` to open psql console
   * create a db for development, run `create user "shopshops_development" with password 'shopspassword';`
   * create a db for test for future use, run `create user "shopshops_test" with password 'shopspassword';`
   * to view list of db, enter `\list` and you shall find db `shopshops_development` and `shopshops_test`
   
 * start server:
    * in terminal redirect to project's directory
    * run `rake db:migrate`
    * then run `rails server` to start your server
    * your server is listening on port 3000, type `localhost:3000` in browser address bar and you are now on rails
 
 * ngrok:
    * now you have to expose your local web server to the internet
    * we recommend using ngrok. [Follow this tutorial to set it up](https://dashboard.ngrok.com/get-started)
    * redirect to directory where you downloaded it, run command `./ngrok http 3000` and now you are exposed to the Internet
    * We recommend you to use a subdomain, run command `./ngrok http -subdomain=<YOUR_SUBDOMAIN> 3000`
    * you shall see the domain ngrok assigned to you in the terminal, or go to ngrok's console `localhost:4040` in browser, it provides helpful info and logs of every single request
 
 * change base url:
    * you are now running your local server, you have to modify the base url
    * go to .env file, change the field `BASE_URL=https://shopsshops.ngrok.io` to `BASE_URL=<LOCAL_URL_GIVEN_BY_NGROK>`
    * restart server if necessary
 
    