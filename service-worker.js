const CACHE_NAME = 'vajra-shell-v1';
const SHELL_FILES = ['./vajra_gym_erp.html','./manifest.webmanifest','./vajra-icon.svg'];

self.addEventListener('install',event=>{
  event.waitUntil(caches.open(CACHE_NAME).then(cache=>cache.addAll(SHELL_FILES)).then(()=>self.skipWaiting()));
});

self.addEventListener('activate',event=>{
  event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(key=>key!==CACHE_NAME).map(key=>caches.delete(key)))).then(()=>self.clients.claim()));
});

self.addEventListener('fetch',event=>{
  const request = event.request;
  const url = new URL(request.url);
  if(request.method !== 'GET' || url.origin !== self.location.origin) return;
  if(request.mode === 'navigate'){
    event.respondWith(fetch(request).catch(()=>caches.match('./vajra_gym_erp.html')));
    return;
  }
  event.respondWith(caches.match(request).then(cached=>cached || fetch(request)));
});
