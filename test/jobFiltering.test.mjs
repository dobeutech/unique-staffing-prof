import assert from "node:assert/strict"
import { describe, it } from "node:test"
import { filterJobs } from "../node_modules/.test-dist/jobFiltering.js"

const jobs = [
  { title: "Warehouse Associate", category: "Operations", location_zip: "07753" },
  { title: "Delivery Driver", category: "Transportation", location_zip: "07754" },
  { title: "Office Coordinator", category: "Administration", location_zip: "10001" },
]

describe("filterJobs", () => {
  it("applies title/category and ZIP filters through one derived result", () => {
    assert.deepEqual(filterJobs(jobs, "  operations  ", "077"), [jobs[0]])
    assert.deepEqual(filterJobs(jobs, "DRIVER", "07754"), [jobs[1]])
  })

  it("returns every job when both filters are blank", () => {
    assert.deepEqual(filterJobs(jobs, "  ", ""), jobs)
  })

  it("returns no jobs when either active filter does not match", () => {
    assert.deepEqual(filterJobs(jobs, "driver", "10001"), [])
  })
})
