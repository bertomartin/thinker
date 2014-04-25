thinker
=======

Example fast JSON API using RethinkDB and just passing JSON through (no models).

Uses PUT to create or replace documents, PATCH to update documents (UUID must be supplied by the client, thus ensuring idempotency).

Follows jsonapi.org standard (not fully implemented yet). Example routes:

```
GET    /users                            users#index        List all users  
GET    /users/:ids                       users#index        Show specified user or users  
PUT    /users/:id                        users#update       Create or replace user <uuid>  
PATCH  /users/:id                        users#update       Update user <uuid>  
DELETE /users/:id                        users#update       Delete user <uuid>

GET    /users/:user_id/articles/:ids     articles#index  
GET    /users/:user_id/articles          articles#index  
PUT    /users/:user_id/articles/:id      articles#update  
PATCH  /users/:user_id/articles/:id      articles#update  
DELETE /users/:user_id/articles/:id      articles#update
```

"Models" are only used for validation and are never instantiated.

Can sort on fields:

```
/articles?sort=user_id,-title
```

(Ascending on user_id, descending on title.)

Can also specify fields (but only if they've been whitelisted):

```
/articles?fields=title,body,created_at
```

More to come. This is a first pass. Suggestions welcome.
