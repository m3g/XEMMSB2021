function readfile(file; cols=(1,2))

#count the number of data that tha file have.

  f =open(file)
    ndata = 0
      for line in eachline(f)
	   if line[1:1] != "#"  && line[1:1] != "@"
	      ndata = ndata + 1
	   end
      end
  seek(f,0)


#Creation of the two vectors that will store the data.

 x = [0. for i in 1:ndata]
 y = [0. for i in 1:ndata]


#start the for loop to chage the zeros of the vestors to the data of a respective file


   i = 0
  for line in eachline(f)
       if line[1:1] != "#"  && line[1:1] != "@"
	 i= i + 1
	 line_data = split(line)
	 x[i] = parse(Float64,line_data[cols[1]])
         y[i] = parse(Float64,line_data[cols[2]])         
       end
   end
 close(f)

 return ndata, x, y

end


