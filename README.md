# US hub of Shopshops

## Things you may want to cover:

* Ruby version
2.5.1

* Rails version
5.1.6

* Database
PostgresSQL

* 运行test
rspec spec/

* API文档
/docs

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Set up local environment (for Ubuntu & Mac OS):
* Install RVM:
    * i.e. Ruby version manager (Strongly recommended) 
    [Follow this tutorial to install it](https://github.com/rvm/rvm)
    

* Install ruby version 2.5.1:
    * RVM makes your life easier, simply run command `rvm install 2.5.1`
    * If you failed to install it, try running the following commands then retry it:
        ```
         rvmsudo rvm cleanup all
         rvm get master
        ```
 
* Install node.js:
    * Simply run the following commands
        ```
        sudo apt-get update
        sudo apt-get install nodejs
        ```
        
* Install PostgreSQL (psql):
    * Simply run the following commands
        ```
        sudo apt-get update
        sudo apt-get install postgresql postgresql-contrib
        ```
        
* Install bundler and rails:
    * Simply run following commands
        ```
        gem install bundler
        gem install rails
        bundle install
        ```
 * Install Redis
    * Run the following commands:
        ```
        sudo apt-get update
        sudo apt-get install redis-server
        ```
 
 * Create your local databases:
   * Run `sudo -i -u postgres` to open psql console
   * Create a role, run `create user "shopsadmin" with password 'shopspassword';` grant create db permission to this user
   * If you haven't grant create db to `shopsadmin`, do it by `ALTER USER shopsadmin CREATEDB;`
   * Create a db for development, run `create database "shopshops_development" owner "shopsadmin";`
   * Create a db for testing purpose, run `create database "shopshops_test" owner "shopsadmin";`
   * To view list of db, enter `\list` and you shall find db `shopshops_development` and `shopshops_test`
   
 * Start server:
    * In terminal redirect to project's directory
    * Run `rake db:migrate`
    * Then run `rails server` to start your server
    * Your server is listening on port 3000, type `localhost:3000` in browser address bar and press enter. You are now on rails
 
 * Ngrok:
    * Now you have to expose your local web server to the internet
    * We recommend using ngrok. [Follow this tutorial to set it up](https://dashboard.ngrok.com/get-started)
    * Redirect to directory where ngrok is, run command `./ngrok http 3000` and now you are exposed to the Internet
    * We recommend using a subdomain which makes your domain more meaningful. To do that, run command `./ngrok http -subdomain=<YOUR_SUBDOMAIN> 3000`
    * Now you shall see the domain ngrok assigned to you in the terminal. Go to ngrok's console `localhost:4040` in browser, it provides helpful info and logs for every single request
 
 * Change base url:
    * Your local server is now running, you have to modify the base url
    * Go to .env file, change the field `BASE_URL=https://shopshops-hub.herokuapp.com` to `BASE_URL=<LOCAL_URL_GIVEN_BY_NGROK>`
    * Restart server if necessary
 
    
