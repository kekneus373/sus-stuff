# The story of my Acer Aspire E3-112M

<mark><b>NOTE from the future me, kekneus373:</b></mark>

*This was my intro message sent to ChatGPT,
so don't freak out when I address things to "you"* 😅

😈 It is just the begging of the "hell" I've created for myself...

---

I want to tell you a story about this notebook.

It's not bought from eBay. First, I had only a motherboard with an attached 2 GB RAM module, and a touchpad, which were left over after a repaired machine. The mobo was suspected to be damaged, because Windows wouldn't install on it (freezing on bootup). I thought that it might be a driver issue. Fortunately, I could start the board without any laptop-stuff connected to it (like speakers, buttons, USB ports, battery, etc.).

Found some old 250 GB hard drive in the pulled computer parts bin, attached it, and hooked up my Linux Mint XFCE flash drive. Tried a couple of things like web browsing, watching local videos, taking screenshots, and editing documents. Everything went fine and smoothly (even on 2G) after disabling HW acceleration using my older method, mentioned here. But the issues were much heavier than it looked at this point...

## Getting it running

Ok, I've installed Linux without any troubles (thanks Acer for good firmware 👍). Rebooted, and voila — a great ultra-economic (**7 Watts** on average) workhorse. My father was shocked that it somehow worked well :)

Next, it was time to assemble everything to actually use it. Went to the well-known Ukrainian online marketplace Prom.ua and found **everything** to build this thing from the ground up! Also ordered a box of small screws for laptops. This stuff cost me around $100 bucks. Kinda cheap, isn't it? While packing a lot of power inside — Celeron N2840! IMO, the "horsepower"/wattage/price factor is just perfect here.

That happened in November. Nowadays, I use it every day (currently writing to you). I love its keyboard, the 11.6" 1366x768 bright and contrasty IPS screen (for real), and stylish design. Acer Aspire E3-112M... from almost nothing! It feels like you're using a MacBook :)

## When problems started

When I started using it as a daily driver, issues started arising:

1. Terrible OS and app experience because of too much swap use;
2. Freezes caused by certain programs and websites (yes, even with hardware acceleration features turned off everywhere I could do so);
3. Because of #1, Chromium takes nearly 40 seconds to fully launch with no tabs open!

The whole experience became worse from day to day. I even regretted my choice and the money spent, but didn't give up — "hey, let's make it work!" With no money for upgrades, I started looking over the internet for how to improve my situation, and found only comments and articles like *"Dude, buy an SSD and upgrade."* Hate this!!

## The fix

After thinking "maybe ChatGPT could help me?", I decided to finally explore your possibilities and tell you everything. Remember when you told me about all this stuff: `systemd-analyze`, `sysctl vm.swappiness=1`, `zswap`, `llvmpipe`? That's everything I needed, as a person without a lot of money to spend on useless upgrades (until something breaks)! When I applied each trick, I was surprised how well it performs now. Outstanding! With no money spent at all!

## The trade-off

But at the same time, I pay a "price" for one of these features — `llvmpipe`. While being an ultimate software rendering solution, especially in case you have a glitchy (i)GPU, it decreases overall performance by almost half. YouTube videos play at 15 FPS, higher CPU usage. But whatever it causes, the main thing here — **IT WORKS!!** No freezes! I've already become fine with it; it doesn't annoy me now. Agree with me: when it's hard for you to buy new hardware every few years, that's the only way to use the newest technology (Windows 7 users 🦍🗿), while not paying hundreds or thousands of dollars for it.

Thanks again for your work — it's so important and useful for me! I hope you enjoyed this story :)

🕒 *15.01.2024 (16:43)*
