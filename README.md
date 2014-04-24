thinker
=======

Example fast JSON API using RethinkDB and just passing JSON through (no models).

Uses PUT to create or replace documents, PATCH to update documents (UUID must be supplied by the client).

Follows jsonapi.org standard (not fully implemented yet). Example routes:

GET    /users                            users#index  
GET    /users/:ids                       users#index  
PUT    /users/:id                        users#update  
PATCH  /users/:id                        users#update  
DELETE /users/:id                        users#destroy

GET    /users/:user_id/articles/:ids     articles#index  
GET    /users/:user_id/articles          articles#index  
PUT    /users/:user_id/articles/:id      articles#update  
PATCH  /users/:user_id/articles/:id      articles#update  
DELETE /users/:user_id/articles/:id      articles#destroy

Can sort on fields:

/articles?sort=user_id,-title

(Ascending on user_id, descending on title.)

Can also specify fields (but only if they've been whitelisted):

/articles?fields=title,body,created_at
