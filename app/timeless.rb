require 'pathname'
require_relative 'post_page'
require_relative 'file_page'
require_relative 'change'

class Timeless
  ROOT = Pathname.new(File.expand_path('..', __dir__))

  def self.main
    @main ||= new
  end

  attr_reader :directory, :pages, :changes

  def initialize(directory: ROOT)
    @directory = directory

    @pages = read_pages.sort_by { |page| page.title || page.key }
    @page_map = {}
    @pages.each do |page|
      @page_map[page.key] = page
    end
    @changes = read_changes
  end

  def lookup_page(key)
    @page_map[key]
  end

  def read_pages
    read_posts + read_files
  end

  def read_files
    (@directory + 'files').children
      .map { |path| FilePage.new(path) }
  end

  def read_posts
    (@directory + 'posts').children
      .map { |path| PostPage.new(path) }
  end

  def read_changes
    (@directory + 'changes').children
      .map { |path| Change.new(path) }
      .sort_by(&:id).reverse
  end
end

