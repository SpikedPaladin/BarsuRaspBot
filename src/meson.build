bot_deps = [
    dependency('telegram-glib-1.0'),
    dependency('gxml-0.20'),
    dependency('cairo')
]

bot_sources = files(
    'data/keyboards.vala',
    
    'barsu-bot.vala',
    'main.vala',
)

# Load modules
subdir('modules')

executable(
    'barsu-rasp-bot',
    
    bot_sources,
    dependencies: bot_deps,
    install: true,
)
