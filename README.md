# Ticket System

## Description

This app allows searching for data related to ticket.

In particular, it allows searching for tickets and the users assigned to them, and also searching for users and their assigned tickets.

## Setup

Install the following ruby gems:

```
gem install diff/lcs
gem install forwardable
gem install json-schema
gem install rpsec
gem install rubocop
gem install terminal-table
gem install yaml
```

## Usage

Execute the entry point script `main.rb`:

```
ruby main.rb
```

This will:

* Load the `tickets.json` and `users.json` files into the system, and then
* Show a command prompt to enter queries to retrieve data.

To graceful exist the system, type any of the following:

```
exit
quit
q
```

### Queries

Queries have the following format:

```
select * from <table> [where <condition>]
```

Currently, all fields (columns) are retrieved (no field filtering is supported).

The table name correspond to the json file names used to load the data (i.e. `tickets` and `users`).

The `where` block is optional: all rows will be retrived if not specified.

The `condition` part is an expression that matches the ruby conditional expressions. For example:

```
name == 'Cross Barlow'
tags.include?('Texas')
assignee_id < 3
/svalbard/ =~ subject.downcase
```

Invalid operatios (ex: using the `=` operator) or operations on non-existent fields are excluded, so only the remaining valid conditions will be used to filter results. For example:

```
>> select * from users where name = 'Cross Barlow' and _id < 5
```

will return all users whose `_id` field is lower than five, irrespective of their name.

### Results

When data for a table is requested, matching data for a linked table is also retrieved (for example, when asking for tickets, data for users linked to thise tickets is also returned).

Data is returned in different tables. For the example above, the system will output one table with a ticket data, and another table with all users related to that ticket.

## Configuration

The system specifies the tables to be loaded on the `main.rb` file. If more and/or different tables need to be changed they must be added there.

In addition to specifying the table, the system requires the relationship, or `foreign keys`, between tables. For example, the current configuration sets the following foreign key on table tickets, specified in Json format:

```
[{"key": "assignee_id", "table": "users"}]
```

## Security

This system DOES ALLOW code injection, so use it with care. For example, this command:

```
>> select * from users where system('date')
```

will return the system date. By the time this was written the following was returned:

```
Sun 25 Jul 2021 17:38:27 AEST
```

Future work

* Fix the security issue mentioned above.
* Use indexes to improve the search performance.
* Support fields to be returned.
* Support returning joined tables instead of having related results separated.

## Author

Jose Miguel Armijo <jm.armijo.f@gmail.com>

https://github.com/jm-armijo/ticket-system
