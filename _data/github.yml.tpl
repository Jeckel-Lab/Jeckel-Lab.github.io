recent_contributions:
{{range recentContributions 10}}
    - name: {{.Repo.Name}}
      description: "{{.Repo.Description}}"
      url: {{.Repo.URL}}
      occurred: {{.OccurredAt}}
{{end}}
recent_pull_requests:
{{range recentPullRequests 10}}
    - title: {{.Title}}
      url: {{.URL}}
      state: {{.State}}
      createdAt: {{.CreatedAt}}
      repository:
        - name: {{.Repo.Name}}
        - description: "{{.Repo.Description}}"
        - url: {{.Repo.URL}}
{{end}}
recent_stars:
{{range recentStars 10}}
    - name: {{.Repo.Name}}
      description: "{{.Repo.Description}}"
      url: {{.Repo.URL}}
      stars: {{.Repo.Stargazers}}
{{end}}
recent_repos:
{{range recentRepos 10}}
    - name: {{.Name}}
      description: "{{.Description}}"
      url: {{.URL}}
      stars: {{.Stargazers}}
{{end}}
