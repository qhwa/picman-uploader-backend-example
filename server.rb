require 'sinatra'
require 'haml'
require 'fileutils'

FILE_FIELD_NAME = 'FileData'

# POST /
# 尝试保存图片，并返回图片地址
post '/' do

  case file_field 
    when String;  receive_as_plain_text
    when Hash;    receive_as_blob
  end

  img_url  = url("/img/#{filename}")

  output = %Q({
    "dataList"    : [456347479],
    "result"      : "success",
    "miniImgUrls" : ["#{img_url}"],
    "imgUrls"     : ["#{img_url}"]
  })

  should_delay? ? delayed_output(output) : output
end

def filename
  params['fname'] || params['filename'] || params['Filename']
end

def file_field
  params[FILE_FIELD_NAME]
end

def receive_as_blob
  FileUtils.cp file_field[:tempfile], image_path(filename)
end

def receive_as_plain_text
  # Flash提交过来的文件内容已经变成了
  # 一个字符串，可以以表单字段的方式
  # 获取到, 将文件内容（已经是字符串）
  # 写入磁盘
  File.open( image_path(filename), 'w') { |f| f.write file_field }
end

def should_delay?
  params.has_key? :delay
end

def delayed_output(output)
  stream do |out|
    out << ' '
    sleep params[:delay].to_i
    out << output
  end
end


# POST /fail
# 永远会上传失败的接口
# 随机产生一个错误代码返回
post '/fail' do
  %Q({
    "result"  : "fail",
    "msg"     : "#{%w(imgTooBig imgTypeErr maxImageSpaceExceed maxImgPerAlbumExceeded).sample}"
  })
end

# POST /fail/自定义错误信息
# 永远会上传失败的接口
# 使用自定义错误信息
post '/fail/:msg' do |msg|
  %Q({
    "result"  : "fail",
    "msg"     : "#{msg}"
  })
end

# POST /random
# 随机返回成功或失败
post '/random' do 
  if rand > 0.5
    call env.merge("PATH_INFO" => '/fail')
  else
    call env.merge("PATH_INFO" => '/' )
  end
end

get '/img/:file' do |file|
 send_file image_path(file)
end

get('/') { haml :demo }

def image_path(file)
 "tmp/image-#{file}"
end
