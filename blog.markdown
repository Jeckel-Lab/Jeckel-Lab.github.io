---
layout: page
# title: Blog
permalink: /blog
menu_item: blog
---
{%- if site.posts.size > 0 -%}
<div class="card" style="--card-color: var(--purple-color)">
<h2 class="card-title">Derniers articles</h2>
<!-- <div class="spinner">Content is beeing loaded</div> -->

<ul>
    {%- assign date_format = site.minima.date_format | default: "%b %-d, %Y" -%}
    {%- for post in site.posts -%}
    <li>{{ post.date | date: date_format }} <a href="{{ post.url | relative_url }}">{{ post.title | escape }}</a></li>
    {%- endfor -%}
</ul>
<div class="card-footer">subscribe <a href="{{ "/feed.xml" | relative_url }}">via RSS</a></div>
</div>
{%- endif -%}