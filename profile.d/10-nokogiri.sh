# this speeds up nokogiri gem compilation by using libxml/libxslt from system.
# not setting this will cause nokogiri to compile its own copy of libxml/libxslt.
export NOKOGIRI_USE_SYSTEM_LIBRARIES=true
