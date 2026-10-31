The value  `1024`  in  `-accel tcg,tb-size=1024`  is expressed in  **megabytes (MB)**.

Therefore:

-   `tb-size=1024`  =  **1024 MiB**  ≈  **1 GiB**  of translation cache.

This is explicitly stated in the email thread you provided, where Alex Bennée writes:

> "The total size of the translation cache is  **tb-size in MBs**  (as in  `-accel tcg,tb-size=1024`)."

So if you set it to  `1024`, you're allocating roughly  **1 GiB**  of memory for the TCG translation block cache.

[](https://blueprints.launchpad.net/nova/+spec/control-qemu-tb-cache)

blueprints.launchpad.net  › nova › +spec › control-qemu-tb-cache

Add ability to control the memory used by fully emulated QEMU gu... : Blueprints : OpenStack Compute (nova)

And upstream libvirt is in the process of wiring it up[3][4][5] via &quot;tb-cache&quot;: ...  Both MiB and KiB are valid units in the XML for `tb-cache`; internally libvirt stores it in KiB.

[](https://lists.gnu.org/archive/html/qemu-devel/2020-07/msg05235.html)

lists.gnu.org  › archive › html › qemu-devel › 2020-07 › msg05235.html

Re: TB Cache size grows out of control with qemu 5.0

So on one hand I&#x27;m suggesting something ... b/accel/tcg/translate-all.c @@ -944,7 +944,7 @@ static void page_lock_pair(PageDesc **re * Users running large scale system emulation may want to tweak their * runtime setup via the tb-size control on the command line. */ -#define DEFAULT_CODE_GEN_BUFFER_SIZE_1 (1 * GiB) +#define DEFAULT_CODE_GEN_BUFFER_SIZE_1 (256 * MiB) #endif #endif ...

[](https://www.mail-archive.com/qemu-devel@nongnu.org/msg723844.html)

mail-archive.com  › qemu-devel@nongnu.org › msg723844.html

Re: TB Cache size grows out of control with qemu 5.0

&gt; &gt; &gt; &gt; &gt; So on one hand I&#x27;m suggesting something like: &gt; &gt; --- a/accel/tcg/translate-all.c &gt; &gt; +++ b/accel/tcg/translate-all.c &gt; &gt; @@ -944,7 +944,7 @@ static void page_lock_pair(PageDesc **re &gt; &gt; * Users running large scale system emulation may want to tweak their &gt; &gt; * runtime setup via the tb-size control on the command line. &gt; &gt; */ &gt; &gt; -#define DEFAULT_CODE_GEN_BUFFER_SIZE_1 (1 * GiB) &gt; &gt; +#define DEFAULT_CODE_GEN_BUFFER_SIZE_1 (256 * MiB) &gt; &gt; The problem we have is any number we pick here is arbitrary.

[](https://airbus-seclab.github.io/qemu_blog/tcg_p3.html)

airbus-seclab.github.io  › qemu_blog › tcg_p3.html

A deep dive into QEMU: TCG memory accesses | QEMU internals

The QEMU TCG job is thus to redirect any guest memory access to address X (whether virtual or physical) to that memory buffer. Obviously, the guest vCPU type and running mode will have an impact on how addresses are translated. This is where the so called QEMU-softmmu enters the game. In system-mode emulation, as opposed to user-mode, and for some architectures the QEMU engine supports a Software Memory Managment Unit (soft-MMU).

[](https://www.qemu.org/docs/master/devel/multi-thread-tcg.html)

qemu.org  › docs › master › devel › multi-thread-tcg.html

Multi-threaded TCG — QEMU documentation

The system currently has a tcg_gen_mb() which will add memory barrier operations if code generation is being done in a parallel context. The tcg_optimize() function attempts to merge barriers up to their strongest form before any load/store operations. The solution was originally developed and tested for linux-user based systems.

[](https://www.qemu.org/docs/master/system/qemu-manpage.html)

qemu.org  › docs › master › system › qemu-manpage.html

QEMU User Documentation — QEMU documentation

Controls the use of split w^x mapping ... systems, this will default off, but one may enable this for testing or debugging. ...  Controls the size (in MiB) of the TCG translation block cache....

[](https://github.com/qemu/qemu/blob/master/tcg/tcg.c)

github.com  › qemu › qemu › blob › master › tcg › tcg.c

qemu/tcg/tcg.c at master · qemu/qemu

has_type = TCG_TARGET_HAS_v256; break; default: has_type = false; break; } · switch (op) { case INDEX_op_discard: case INDEX_op_set_label: case INDEX_op_call: case INDEX_op_br: case INDEX_op_mb: case INDEX_op_insn_start: case INDEX_op_exit_tb: case INDEX_op_goto_tb: case INDEX_op_goto_ptr: return true; · case INDEX_op_qemu_ld: case INDEX_op_qemu_st: tcg_debug_assert(type &lt;= TCG_TYPE_REG); return true; ·

[](https://qemu.weilnetz.de/doc/6.0/system/invocation.html)

qemu.weilnetz.de  › doc › 6.0 › system › invocation.html

Invocation — QEMU documentation

lat is latency value in nanoseconds. bw is bandwidth value, the possible value and units are NUM[M|G|T], mean that the bandwidth value are NUM byte per second (or MB/s, GB/s or TB/s depending on used suffix).

[](https://manpages.debian.org/testing/qemu-system-x86/qemu-system-x86_64.1.en.html)

manpages.debian.org  › testing › qemu-system-x86 › qemu-system-x86_64(1)

qemu-system-x86_64(1) — qemu-system-x86 — Debian testing — Debian Manpages

lat is latency value in nanoseconds. bw is bandwidth value, the possible value and units are NUM[M|G|T], mean that the bandwidth value are NUM byte per second (or MB/s, GB/s or TB/s depending on used suffix).

[](https://www.qemu.org/docs/master/devel/index-tcg.html)

qemu.org  › docs › master › devel › index-tcg.html

TCG Emulation — QEMU documentation

Details about QEMU’s Tiny Code Generator and the infrastructure associated with emulation. You do not need to worry about this if you are only implementing things for HW accelerated hypervisors · © Copyright 2026, The QEMU Project Developers

[](https://github.com/utmapp/UTM/issues/6632)

github.com  › utmapp › UTM › issues › 6632

The UTM(JIT) cannot be set to '-accel tcg,tb-size=256,split-wx=off', otherwise it will crash? · Issue #6632 · utmapp/UTM

Describe the issue After setting the UTM qemu runtime parameters to &#x27;-accel tcg,tb-size=256,split-wx=off&#x27;, a crash will occur： qemu-i386-softmmu: -accel tcg,tb-size=256,split-wx=off: alloca...

[](https://manpages.ubuntu.com/manpages/jammy/man1/qemu-system.1.html)

manpages.ubuntu.com  › jammy › man(1)

Ubuntu Manpage: qemu - QEMU User Documentation

lat is latency value in nanoseconds. bw is bandwidth value, the possible value and units are NUM[M|G|T], mean that the bandwidth value are NUM byte per second (or MB/s, GB/s or TB/s depending on used suffix).

[](https://stackoverflow.com/questions/20675226/qemu-code-flow-instruction-cache-and-tcg)

stackoverflow.com  › questions › 20675226 › qemu-code-flow-instruction-cache-and-tcg

QEMU - Code Flow [ Instruction cache and TCG] - Stack Overflow

I am trying to analyze the QEMU source code. I know its huge and till date there is no official documentation for it. My main areas of concern are the Instruction cache management and TCG operati...

[](https://www.qemu.org/docs/master/devel/tcg-ops.html)

qemu.org  › docs › master › devel › tcg-ops.html

TCG Intermediate Representation — QEMU documentation

TCG instructions or ops operate on TCG variables, both of which are strongly typed. Each instruction has a fixed number of output variable operands, input variable operands and constant operands. Vector instructions have a field specifying the element size within the vector.

[](https://github.com/qemu/qemu/blob/master/tcg/tcg-op.c)

github.com  › qemu › qemu › blob › master › tcg › tcg-op.c

qemu/tcg/tcg-op.c at master · qemu/qemu

void tcg_gen_mb(TCGBar mb_type) { #ifdef CONFIG_USER_ONLY · bool parallel = tcg_ctx-&gt;gen_tb-&gt;cflags &amp; CF_PARALLEL; #else · /* * It is tempting to elide the barrier in a uniprocessor context. * However, even with a single cpu we have i/o threads running in ·

[](https://notes.itsvasugrover.com/kb/embedded/qemu/qemu-performance-optimization/)

notes.itsvasugrover.com  › kb › embedded › qemu › qemu-performance-optimization

QEMU Performance Optimization | Notes - Vasu Grover

TB chaining: When one TB jumps ... eliminates most translation-dispatch overhead in tight loops. The default TCG code cache is  64 MB....

[](https://lists.endsoftwarepatents.org/archive/html/qemu-devel/2020-07/msg05529.html)

lists.endsoftwarepatents.org  › archive › html › qemu-devel › 2020-07 › msg05529.html

Re: TB Cache size grows out of control with qemu 5.0

&gt; &gt; So on one hand I&#x27;m suggesting something like: &gt; --- a/accel/tcg/translate-all.c &gt; +++ b/accel/tcg/translate-all.c &gt; @@ -944,7 +944,7 @@ static void page_lock_pair(PageDesc **re &gt; * Users running large scale system emulation may want to tweak their &gt; * runtime setup via the tb-size control on the command line. &gt; */ &gt; -#define DEFAULT_CODE_GEN_BUFFER_SIZE_1 (1 * GiB) &gt; +#define DEFAULT_CODE_GEN_BUFFER_SIZE_1 (256 * MiB) The problem we have is any number we pick here is arbitrary.

[](https://people.redhat.com/pbonzini/qemu-test-doc/_build/html/topics/Translator-Internals.html)

people.redhat.com  › pbonzini › qemu-test-doc › _build › html › topics › Translator-Internals.html

Translator Internals — QEMU 2.7.0 documentation

QEMU’s dynamic translation backend is called TCG, for “Tiny Code Generator”. For more information, please take a look at tcg/README. Some notable features of QEMU’s dynamic translator are: ... The target CPUs have many internal states which change the way it evaluates instructions. In order to achieve a good speed, the translation phase considers that some state information of the virtual CPU cannot change in it. The state is recorded in the Translation Block (TB).

[](https://manpages.debian.org/testing/qemu-system-common/qemu-system.1.en.html)

manpages.debian.org  › testing › qemu-system-common › qemu-system.1.en.html

qemu-system(1) — qemu-system-common — Debian testing — Debian Manpages

lat is latency value in nanoseconds. bw is bandwidth value, the possible value and units are NUM[M|G|T], mean that the bandwidth value are NUM byte per second (or MB/s, GB/s or TB/s depending on used suffix).

[](https://airbus-seclab.github.io/qemu_blog/tcg_p1.html)

airbus-seclab.github.io  › qemu_blog › tcg_p1.html

A deep dive into QEMU: The Tiny Code Generator (TCG), part 1 | QEMU internals

The QEMU git tree has a README introduction about the TCG which details the IR language. It’s an interesting read for sure. The gen_intermediate_code function is a VM architecture dependent wrapper to the translator_loop generic function. Let’s imagine we were emulating PowerPC code on an Intel x86 host. ... static const TranslatorOps ppc_tr_ops = { .init_disas_context = ppc_tr_init_disas_context, .tb_start = ppc_tr_tb_start, .insn_start = ppc_tr_insn_start, .breakpoint_check = ppc_tr_breakpoint_check, .translate_insn = ppc_tr_translate_insn, .tb_stop = ppc_tr_tb_stop, .disas_log = ppc_tr_disas_log, }; void gen_intermediate_code(CPUState *cs, TranslationBlock *tb, int max_insns) { DisasContext ctx; translator_loop(&amp;ppc_tr_ops, &amp;ctx.base, cs, tb, max_insns); }

[

QEMU tcg tb-size parameter unit MB or MiB](https://search.brave.com/search?q=QEMU%20tcg%20tb-size%20parameter%20unit%20MB%20or%20MiB)

Qwen VL 30B

Oh ok. Ikr it's unrelated but if I've got 5 G of RAM on host and allocated 2 to VM then what is the recommended tb-size?

There isn't a single "recommended"  `tb-size`  that applies to every VM, but with  **5 GB host RAM**  and  **2 GB allocated to the VM**, you have some headroom to increase the cache beyond the default to reduce translation churn, especially for workloads with dynamic code generation.

Here’s a practical approach:

### Guidelines for Setting  `tb-size`

1.  **Default**: QEMU often defaults to a relatively small cache (often 1–4 MB depending on version and configuration).
2.  **Rule of Thumb**:
    -   For a  **light workload**  (e.g., basic Linux shell, static binaries):  **1–2 GB**  is usually more than enough.
    -   For a  **heavy workload**  (e.g., compiling code, running dynamic languages, heavy JIT usage in guest):  **2–4 GB**  can help significantly.
3.  **Host RAM Constraint**:
    -   You have  **5 GB total**, 2 GB is already used by the VM.
    -   That leaves  **~3 GB**  for the host OS + QEMU overhead (including the TCG cache).
    -   Allocating  **2–3 GB**  for  `tb-size`  is generally safe, but ensure you leave enough for the host OS and other VM components.

### Recommended Starting Point

-   **Try  `tb-size=2048`  (2 GB)**  first.
    -   This is a good balance: large enough to help with cache churn, but not so large that it starves the host.
-   Monitor performance:
    -   Use  `info jit`  in QEMU's HMP (Human Monitor Protocol) to check translation block flushes and hit rates.
    -   If flushes are still high and you have RAM to spare, try increasing to  **3072 (3 GB)**.

### How to Set It

bash

Copy

```
qemu-system-x86_64 -m 2G -accel tcg,tb-size=2048 ...
```

### When to Adjust

-   **If you see high  `tb_flush`  counts**  (via  `info jit`), increase  `tb-size`.
-   **If the host starts swapping**  or running slow, decrease  `tb-size`.


> Written with [StackEdit](https://stackedit.io/).
