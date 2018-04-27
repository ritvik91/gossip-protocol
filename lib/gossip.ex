defmodule Gossip do


  use GenServer
  @moduledoc """
  Documentation for Gossip.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Gossip.hello
      :world

  """

  def start_link do
    GenServer.start_link(Gossip,[0,""])
  end

  def init(initial_data) do
    [count, rumour] = initial_data
    {:ok, [count, rumour]}
  end

  def get_state(pid) do
    GenServer.call(pid, {:get_the_state})
  end

  def handle_call({:get_the_state}, _from, my_state) do
    {:reply, my_state, my_state}
  end

  def set_state(pid, new_data) do
    GenServer.cast(pid, {:set_the_state, new_data})
  end

  def handle_cast({:set_the_state, new_data}, my_state) do
    my_state = new_data
    {:noreply, my_state}
  end


 # def handle_call({:send_the_message, pid, pid2}, _from, my_state) do
 #     [count, rumour] = get_state(pid)

  #    if count < 10 do
  #      GenServer.call(pid2, {:receive_the_message, pid2, pid, rumour})
  #    end
  #    {:reply, my_state, my_state}
  #end


  def handle_call({:receive_the_message, nodelist, rumour}, _from, my_state) do
    
    [count, rumour1] = my_state

   # IO.puts "Roumer befor updation :" <> rumour

    count = count + 1
  

    my_state = [count, rumour]

    [count1, rumour1] = my_state


   if count <= 10 do
      IO.puts "\n"
      IO.puts "Process:"
      IO.inspect self() 
      IO.inspect my_state
      IO.puts "From"
      IO.inspect _from 
    end  

    {:reply, my_state, my_state}
  end




  def sendmessage(sender, nodelist, topology) do
    GenServer.cast(sender, {:start_sending, sender, nodelist, topology}) 
  end


  def handle_cast({:start_sending, sender, nodelist, topology}, my_state) do    
      [count, rumour] = my_state

      if count <= 10  do
        startsendingmessages(sender,nodelist,my_state, topology)
      end  
      
      {:noreply, my_state}  
  end


  def getreceiverfrom2D(sender, nodelist) do
    neighbourlist = []
    sender = {:ok,sender}
    ind = Enum.find_index((nodelist), fn(x) -> x == sender end)
    len = length(nodelist)
    n = sqrt(len)

    IO.puts "sqrt - "
    IO.puts n

    if n*n<len do
      n=n+1
    end

    i = ind/n
    j = ind%n

    neighbourlist = getNeighbourList2D(neighbourlist,i-1,j,n,len)
    neighbourlist = getNeighbourList2D(neighbourlist,i+1,j,n,len)
    neighbourlist = getNeighbourList2D(neighbourlist,i,j-1,n,len)
    neighbourlist = getNeighbourList2D(neighbourlist,i,j+1,n,len)
    
    receiver = Enum.random(neighbourlist)

    receiver
  end

  def getNeighbourList2D(neighbourlist,i,j,n,len) do

    index = i*n + j
    if i<0 || i>=n || j<0 || j>=n || index>=len do
      index = 0
      {:ok,pid} = Enum.at(nodelist,index)
      neighbourlist = delete(neighbourlist,pid)
    end
    
     {:ok,pid} = Enum.at(nodelist,index)
     neighbourlist = neighbourlist ++ [pid]

  end



  def getreceiverfromList(sender, nodelist) do

     {:ok,receiver} = Enum.random(nodelist)

      if sender == receiver do
        receiver = getreceiverfromList(sender,nodelist)
      end  
    
    receiver

    
  end

  def handle_cast({:start_sending_from_receiver, nodelist, topology, receiver}, my_state) do
    IO.puts "In here"
    IO.inspect self()
    sendmessage(self(), nodelist, topology)
    {:noreply, my_state}
  end

 
 
  def startsendingmessages(sender, nodelist, my_state, topology) do
    
      # IO.puts "self"
      #IO.inspect self()
      [count, rumour] = my_state

        #{:ok, processid} = start_link()
        # state = GenServer.call(processid, {:get_sender_state, sender}) 
      
     
      #[count,rumour] = state
    
      #IO.puts count 

      if topology == "full" do
        receiver = getreceiverfromList(sender, nodelist)
      end

      if count < 10 do
        GenServer.call(receiver, {:receive_the_message,nodelist,rumour})
      end

      [count1, rumour1] = get_state(receiver)

      #IO.puts "Receiver: "
      #IO.inspect receiver

      #IO.puts "count of receiver: "
      #IO.puts count1
      
      if count1 >= 1  do
        #sendmessage(receiver, nodelist, topology)
        GenServer.cast(receiver, {:start_sending_from_receiver, nodelist, topology, receiver})
      end

        #startsendingmessages(sender,nodelist,my_state, topology)
        #sendmessage(sender, nodelist, topology)

  end


  def main(args \\ []) do
    
    {_, input, _} = OptionParser.parse(args, switches: [])

    [arg1 | list]=input;
    numNodes=String.to_integer arg1
    topology=hd(list)
    algorithm=hd(tl(list))
   
   # IO.puts topology
   # IO.puts algorithm

    IO.inspect self()

    spawn(fn() -> process1(numNodes, topology) end)

    

    #for n<- 1..10 do
    #  start_link()
    #end  

    doloop()

  end
 
  def doloop() do
    doloop()
  end
 
  def process1(numNodes, topology) do

    IO.puts "printing this"
    IO.inspect self()
     
    nodelist = Enum.map((1..numNodes), fn(x)-> {:ok,pid} = start_link() end) 
    
    IO.inspect nodelist 

    {:ok, sender} = Enum.at(nodelist,0)

    set_state(sender,[1,"Hello"])
  

    sendmessage(sender, nodelist, topology)

    doloop()

  end

  def hello do
    :world
  end
end
