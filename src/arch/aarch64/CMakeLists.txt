
#set(CMAKE_ASM_NASM_OBJECT_FORMAT "elf32")

### aarch64 arch specific ###
set(ARCH_OBJECTS
    arch_start.asm
    exceptions.asm
    threads.asm
)
set(ARCH_SOURCES
  paging.cpp
  cpu.cpp
  timer.cpp
  syscall_entry.cpp
)
enable_language(ASM)

set_source_files_properties(${ARCH_OBJECTS} PROPERTIES COMPILE_FLAGS "-x assembler-with-cpp")

add_library(arch STATIC ${ARCH_SOURCES} ${ARCH_OBJECTS})

set_target_properties(arch PROPERTIES LINKER_LANGUAGE CXX)
configure_file(linker.ld ${CMAKE_BINARY_DIR})

install(TARGETS arch DESTINATION ${ARCH}/lib)
install(FILES linker.ld DESTINATION ${ARCH})
