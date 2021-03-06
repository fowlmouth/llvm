## This header declares the C interface to the Target and TargetMachine
## classes, which can be used to generate assembly or object files.
##
## Many exotic languages can interoperate with C code but have a harder time
## with C++ due to name mangling. So in addition to C, this interface enables
## tools written in such languages.

import llvm_core, llvm_target

include llvm_lib

when defined(static_link):
  {.passL: gorge("llvm-config --libs target").}

type
  TargetMachineRef* = ptr object
  TargetRef* = ptr object

type
  CodeGenOptLevel* = enum
    CodeGenLevelNone
    CodeGenLevelLess
    CodeGenLevelDefault
    CodeGenLevelAggressive

  RelocMode* = enum
    RelocDefault
    RelocStatic
    RelocPIC
    RelocDynamicNoPic

  CodeModel* = enum
    CodeModelDefault
    CodeModelJITDefault
    CodeModelSmall
    CodeModelKernel
    CodeModelMedium
    CodeModelLarge

  CodeGenFileType* = enum
    AssemblyFile
    ObjectFile

proc getFirstTarget*: TargetRef {.importc: "LLVMGetFirstTarget", libllvm.}
  ## Returns the first llvm::Target in the registered targets list.

proc getNextTarget*(t: TargetRef): TargetRef {.importc: "LLVMGetNextTarget",
                                              libllvm.}
  ## Returns the next llvm::Target given a previous one (or null if there's none)

# Target

proc getTargetFromName*(name: cstring): TargetRef {.
  importc: "LLVMGetTargetFromName", libllvm.}
  ## Finds the target corresponding to the given name and stores it in T.
  ## Returns 0 on success.

proc getTargetFromTriple*(triple: cstring, t: ptr TargetRef,
                          errorMessage: cstringArray): Bool {.
  importc: "LLVMGetTargetFromTriple", libllvm.}
  ## Finds the target corresponding to the given triple and stores it in T.
  ## Returns 0 on success. Optionally returns any error in ErrorMessage.
  ## Use LLVMDisposeMessage to dispose the message.

proc getTargetName*(t: TargetRef): cstring {.importc: "LLVMGetTargetName",
                                            libllvm.}
  ## Returns the name of a target. See llvm::Target::getName

proc getTargetDescription*(t: TargetRef): cstring {.
  importc: "LLVMGetTargetDescription", libllvm.}
  ## Returns the description  of a target. See llvm::Target::getDescription

proc targetHasJIT*(t: TargetRef): Bool {.importc: "LLVMTargetHasJIT", libllvm.}
  ## Returns if the target has a JIT

proc targetHasTargetMachine*(t: TargetRef): Bool {.
  importc: "LLVMTargetHasTargetMachine", libllvm.}
  ## Returns if the target has a TargetMachine associated

proc targetHasAsmBackend*(t: TargetRef): Bool {.
  importc: "LLVMTargetHasAsmBackend", libllvm.}
  ## Returns if the target as an ASM backend (required for emitting output)

# Target Machine

proc createTargetMachine*(t: TargetRef, triple: cstring, cpu: cstring,
                          features: cstring, level: CodeGenOptLevel,
                          reloc: RelocMode, codeModel: CodeModel):
                          TargetMachineRef {.importc: "LLVMCreateTargetMachine",
                                            libllvm.}
  ## Creates a new llvm::TargetMachine. See llvm::Target::createTargetMachine

proc disposeTargetMachine*(t: TargetMachineRef) {.
  importc: "LLVMDisposeTargetMachine", libllvm.}
  ## Dispose the LLVMTargetMachineRef instance generated by
  ## LLVMCreateTargetMachine.

proc getTargetMachineTarget*(t: TargetMachineRef): TargetRef {.
  importc: "LLVMGetTargetMachineTarget", libllvm.}
  ## Returns the Target used in a TargetMachine

proc getTargetMachineTriple*(t: TargetMachineRef): cstring {.
  importc: "LLVMGetTargetMachineTriple", libllvm.}
  ## Returns the triple used creating this target machine. See
  ## llvm::TargetMachine::getTriple. The result needs to be disposed with
  ## LLVMDisposeMessage.

proc getTargetMachineCPU*(t: TargetMachineRef): cstring {.
  importc: "LLVMGetTargetMachineCPU", libllvm.}
  ## Returns the cpu used creating this target machine. See
  ## llvm::TargetMachine::getCPU. The result needs to be disposed with
  ## LLVMDisposeMessage.

proc getTargetMachineFeatureString*(t: TargetMachineRef): cstring {.
  importc: "LLVMGetTargetMachineFeatureString", libllvm.}
  ## Returns the feature string used creating this target machine. See
  ## llvm::TargetMachine::getFeatureString. The result needs to be disposed with
  ## LLVMDisposeMessage.

proc getTargetMachineData*(t: TargetMachineRef): TargetDataRef {.
  importc: "LLVMGetTargetMachineData", libllvm.}
  ## Returns the llvm::DataLayout used for this llvm:TargetMachine.

proc setTargetMachineAsmVerbosity*(t: TargetMachineRef, verboseAsm: Bool) {.
  importc: "LLVMSetTargetMachineAsmVerbosity", libllvm.}
  ## Set the target machine's ASM verbosity.

proc targetMachineEmitToFile*(t: TargetMachineRef, m: ModuleRef,
                              filename: cstring, codegen: CodeGenFileType,
                              errorMessage: cstringArray): Bool {.
  importc: "LLVMTargetMachineEmitToFile", libllvm.}
  ## Emits an asm or object file for the given module to the filename. This
  ## wraps several c++ only classes (among them a file stream). Returns any
  ## error in ErrorMessage. Use LLVMDisposeMessage to dispose the message.

proc targetMachineEmitToMemoryBuffer*(t: TargetMachineRef, m: ModuleRef,
                                      codegen: CodeGenFileType,
                                      errorMessage: cstringArray,
                                      outMemBuf: ptr MemoryBufferRef): Bool {.
  importc: "LLVMTargetMachineEmitToMemoryBuffer", libllvm.}
  ## Compile the LLVM IR stored in \p M and store the result in \p OutMemBuf.

# Triple

proc getDefaultTargetTriple*: cstring {.importc: "LLVMGetDefaultTargetTriple",
                                       libllvm.}
  ## Get a triple for the host machine as a string. The result needs to be
  ## disposed with LLVMDisposeMessage.

proc addAnalysisPasses*(t: TargetMachineRef, pm: PassManagerRef) {.
  importc: "LLVMAddAnalysisPasses", libllvm.}
  ## Adds the target-specific analysis passes to the pass manager.
