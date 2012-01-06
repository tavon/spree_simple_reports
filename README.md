SpreeSimpleReport
=================

This is a tool for shop owners to find out how their products perform. As such it concentrates on how much is sold, ie LineItems.

What started as very simple reports (visually still is), now provides quite a host of useful functionality.

Search by (any combination of) :

- Product name contains
- Option name contains
- Taxon name contains
- Property value contains
- within a date range

You can group results, resulting in a stacked bar-graph, but you also get numeric sum for the group. Group results by:

- nothing (just a summary) 
- Taxon
- Product
- Variant
- any (one) Property


And show a bar graph for time interval:

- day
- week
- month

The resulting number may be:

- price
- amount

Useage scenarios
===============

The general idea is to start with an overview and drill down into interesting weak/strong spots with one of the tools. With the idea of understanding your sales, possibly changing the offer as a result or creating promotions.

Start with a year view by month, and group by say Taxon. As a result you see which of your Taxons sells most, and when. This may help you to create promotions at the right time for example.

Say you thus found your strongest Taxons but want to break it down by whatever properties you use. We have e.g. Supplier. So enter the taxon name into the taxon field, and group by the property: Thus you find the best selling supplier in that taxon and you may wan to add a cross-sell for it, or an up-sell for similar product by other suppliers.

Then you could add the supplier name to the property search field, and then group by Product. You then see the best selling Products of that Supplier in that Taxon, or if you remove the taxon name from the search, the best selling Products of that supplier.

In fact I often alternate between two properties. Search by one property, group by another and back and forth. 

Also, if you have products with many Variants, you can search by that Product Name. If you then group by Variant you find the strongest, but also the weakest which you may wan to remove from your offer. . . . 

Installation
===========

I'm not releasing gems now. It's not really beta yet, but maybe useful to someone. So the well known gem line is:

gem 'spree_simple_reports', :git => 'git://github.com/dancinglightning/spree_simple_reports.git'

There is no external dependency and the only javascript file is referenced from the one template. So no further actions should be needed.

Warning: Do not do silly queries as they will slow down your production. For intensive work I suggest to copy your database, ie with yaml_db, to your local machine first.

Issues
=======

The metasearch with subsequent ruby code approach has served well to get the project up quick. For larger datasets a more hand crafted sql approach may be needed.

As the search searches LineItems , items that are in non completed orders are included. Quite trivial fix, just never got around to it as we don't have that problem.

Also it is quite simple to grind your database and server to a halt by grouping by variant, and reporting a year by day.
  
Plans
=====

Vague Plans exist to introduce also:

- Reports about inventory
- Reports about Order numbers
- Grouing by customer


Copyright (c) 2011 [Torsten Rüger], released under the New BSD License
