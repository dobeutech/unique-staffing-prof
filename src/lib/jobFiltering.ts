export interface FilterableJob {
  title: string
  category: string
  location_zip: string
}

export function filterJobs<T extends FilterableJob>(
  jobs: readonly T[],
  searchTitle: string,
  searchZip: string
): T[] {
  const titleQuery = searchTitle.trim().toLowerCase()
  const zipQuery = searchZip.trim()

  return jobs.filter(job => {
    const matchesTitle = !titleQuery ||
      job.title.toLowerCase().includes(titleQuery) ||
      job.category.toLowerCase().includes(titleQuery)
    const matchesZip = !zipQuery || job.location_zip.startsWith(zipQuery)

    return matchesTitle && matchesZip
  })
}
