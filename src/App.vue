<script setup>
import { computed, onMounted, ref } from 'vue'

const items = ref([])
const reportedCount = ref(0)
const isLoading = ref(true)
const errorMessage = ref('')

const apiBaseUrl = (import.meta.env.VITE_API_BASE_URL ?? '').replace(/\/$/, '')

const itemCountLabel = computed(() => {
  const count = reportedCount.value || items.value.length
  return `${count} ${count === 1 ? 'work' : 'works'}`
})

function formatPrice(item) {
  const amount = Number.isInteger(item.price_cents)
    ? item.price_cents / 100
    : Number(item.price)

  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: item.currency || 'USD',
    maximumFractionDigits: 0,
  }).format(amount)
}

function imageUrl(item) {
  return item.primary_image?.thumbnail_url || item.primary_image?.url || ''
}

async function loadItems() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const response = await fetch(`${apiBaseUrl}/api/items`)

    if (!response.ok) {
      throw new Error(`The gallery returned ${response.status}.`)
    }

    const data = await response.json()

    if (!Array.isArray(data.items)) {
      throw new Error('The gallery response was not in the expected format.')
    }

    items.value = data.items
    reportedCount.value = Number(data.count) || data.items.length
  } catch (error) {
    errorMessage.value =
      error instanceof Error
        ? error.message
        : 'The collection could not be loaded.'
  } finally {
    isLoading.value = false
  }
}

onMounted(loadItems)
</script>

<template>
  <div class="site-shell">
    <header class="site-header">
      <a class="brand" href="#" aria-label="Atelier home">
        <span class="brand-mark" aria-hidden="true">A</span>
        <span>Atelier</span>
      </a>

      <p class="header-note">Independent photographic editions</p>

      <a class="collection-link" href="#collection">
        Collection
        <svg viewBox="0 0 20 20" aria-hidden="true">
          <path d="M4 10h12M11 5l5 5-5 5" />
        </svg>
      </a>
    </header>

    <main>
      <section class="hero" aria-labelledby="page-title">
        <p class="eyebrow">The autumn collection · 2026</p>
        <h1 id="page-title">Art for the<br /><em>everyday extraordinary.</em></h1>
        <div class="hero-footer">
          <p>
            Limited photographic prints, thoughtfully selected for spaces with
            a point of view.
          </p>
          <span aria-hidden="true">Scroll to explore</span>
        </div>
      </section>

      <section id="collection" class="collection" aria-labelledby="collection-title">
        <div class="collection-heading">
          <div>
            <p class="eyebrow">Curated works</p>
            <h2 id="collection-title">The collection</h2>
          </div>
          <p v-if="!isLoading && !errorMessage" class="count">{{ itemCountLabel }}</p>
        </div>

        <div v-if="isLoading" class="art-grid" aria-label="Loading artworks" aria-busy="true">
          <article v-for="index in 8" :key="index" class="art-card skeleton-card">
            <div class="skeleton image-skeleton"></div>
            <div class="skeleton text-skeleton text-skeleton--wide"></div>
            <div class="skeleton text-skeleton"></div>
          </article>
        </div>

        <div v-else-if="errorMessage" class="status-panel" role="alert">
          <span class="status-icon" aria-hidden="true">↗</span>
          <h3>The gallery is taking a moment.</h3>
          <p>{{ errorMessage }} Make sure the backend is running, then try again.</p>
          <button type="button" @click="loadItems">Try again</button>
        </div>

        <div v-else-if="items.length === 0" class="status-panel">
          <span class="status-icon" aria-hidden="true">○</span>
          <h3>A new collection is coming.</h3>
          <p>There are no works to show just yet. Please check back soon.</p>
        </div>

        <div v-else class="art-grid">
          <article v-for="(item, index) in items" :key="item.id" class="art-card">
            <div class="art-image-wrap">
              <img
                v-if="imageUrl(item)"
                class="art-image"
                :src="imageUrl(item)"
                :alt="item.primary_image?.alt || item.ProductName"
                :loading="index < 4 ? 'eager' : 'lazy'"
                :fetchpriority="index < 2 ? 'high' : 'auto'"
              />
              <div v-else class="image-placeholder" aria-hidden="true">
                <span>Atelier</span>
              </div>
              <span class="edition-label">Edition print</span>
            </div>

            <div class="art-details">
              <div>
                <h3>{{ item.ProductName }}</h3>
                <p class="artist">{{ item.artist }}, {{ item.year }}</p>
              </div>
              <p class="price">{{ formatPrice(item) }}</p>
            </div>
            <p class="medium">{{ item.medium }} · {{ item.category }}</p>
          </article>
        </div>
      </section>
    </main>

    <footer class="site-footer">
      <a class="brand brand--footer" href="#" aria-label="Atelier home">
        <span class="brand-mark" aria-hidden="true">A</span>
        <span>Atelier</span>
      </a>
      <p>Art that makes a room feel like yours.</p>
      <p>© 2026 Atelier</p>
    </footer>
  </div>
</template>
