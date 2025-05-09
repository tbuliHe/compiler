cmake_minimum_required(VERSION 3.10)
project(CMINUS_Compiler C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wno-unused-function")

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

set(LEXER_OUTPUT_FILE ${CMAKE_BINARY_DIR}/cminus_lexer.c)
set(PARSER_BASENAME cminus.tab)
set(PARSER_OUTPUT_SOURCE ${CMAKE_BINARY_DIR}/${PARSER_BASENAME}.c)
set(PARSER_OUTPUT_HEADER ${CMAKE_BINARY_DIR}/${PARSER_BASENAME}.h)

add_custom_command(
    OUTPUT ${PARSER_OUTPUT_SOURCE} ${PARSER_OUTPUT_HEADER}
    COMMAND ${BISON_EXECUTABLE} -d -o ${PARSER_OUTPUT_SOURCE} ${CMAKE_CURRENT_SOURCE_DIR}/cminus.y
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/cminus.y
    COMMENT "Running Bison on cminus.y"
    VERBATIM
)

add_custom_command(
    OUTPUT ${LEXER_OUTPUT_FILE}
    COMMAND ${FLEX_EXECUTABLE} -o ${LEXER_OUTPUT_FILE} ${CMAKE_CURRENT_SOURCE_DIR}/cminus.l
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/cminus.l ${PARSER_OUTPUT_HEADER}
    COMMENT "Running Flex on cminus.l"
    VERBATIM
)

add_custom_target(generate_cminus_sources ALL
    DEPENDS ${LEXER_OUTPUT_FILE} ${PARSER_OUTPUT_SOURCE} ${PARSER_OUTPUT_HEADER}
)

add_executable(cminus_parser main.c util.c ${LEXER_OUTPUT_FILE} ${PARSER_OUTPUT_SOURCE})

target_include_directories(cminus_parser PRIVATE
    ${CMAKE_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

add_dependencies(cminus_parser generate_cminus_sources)