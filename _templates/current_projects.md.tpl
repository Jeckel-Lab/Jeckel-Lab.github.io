---
layout: default
permalink: /current_projects/
menu_item: contact
title: Demande de contact avec Jeckel-Lab
# last_modified_at: "2023-09-20 19:48:00"
sitemap: false
---
<div class="card p-1" style="--card-color: var(--green-color);">
    <ul>
    {{range recentContributions 10}}
        <li><a href="{{.Repo.URL}}">{{.Repo.Name}}</a>: {{.Repo.Description}} ({{humanize .OccurredAt}})</li>
    {{end}}
    </ul>
</div>
